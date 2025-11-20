// lib/screens/teacher/teacher_dashboard.dart
import 'package:brainmoto_app/screens/teacher/assessmnet_by_student_screen.dart';
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../models/student_model.dart';
import 'assessment_by_skill_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  String? _selectedGrade;
  List<StudentModel> _students = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser?.schoolId != null &&
        authProvider.currentUser?.assignedGrades != null) {
      if (authProvider.currentUser!.assignedGrades!.isNotEmpty) {
        _selectedGrade = authProvider.currentUser!.assignedGrades!.first;
        await _loadStudents();
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadStudents() async {
    if (_selectedGrade == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schoolId = authProvider.currentUser!.schoolId!;

    setState(() => _isLoading = true);

    // In offline mode, this will load from cache
    FirebaseService.getStudentsByGradeStream(schoolId, _selectedGrade!)
        .listen((students) {
      if (mounted) {
        setState(() {
          _students = students;
          _isLoading = false;
        });
      }
    });
  }

  void _navigateToAssessment(String type) {
    if (type == 'student') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentByStudentScreen(
            students: _students,
            grade: _selectedGrade!,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentBySkillScreen(
            students: _students,
            grade: _selectedGrade!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          Consumer<ConnectivityProvider>(
            builder: (context, connectivity, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (connectivity.pendingSyncCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${connectivity.pendingSyncCount} pending',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                      color: connectivity.isOnline ? Colors.white : Colors.red,
                    ),
                  ],
                ),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync),
                    SizedBox(width: 8),
                    Text('Sync Now'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } else if (value == 'sync') {
                final connectivity =
                    Provider.of<ConnectivityProvider>(context, listen: false);
                await connectivity.syncPendingData();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Connectivity Banner
          Consumer<ConnectivityProvider>(
            builder: (context, connectivity, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: connectivity.isOnline ? Colors.green : Colors.orange,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      connectivity.isOnline
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connectivity.isOnline
                          ? 'Online - Data Syncing'
                          : 'Offline Mode - Data Saved Locally',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Grade Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                final grades = auth.currentUser?.assignedGrades ?? [];
                if (grades.isEmpty) {
                  return const Text('No grades assigned');
                }

                return DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Select Grade',
                    prefixIcon: Icon(Icons.class_),
                  ),
                  items: grades.map((grade) {
                    return DropdownMenuItem(
                      value: grade,
                      child: Text(grade),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGrade = value;
                    });
                    _loadStudents();
                  },
                );
              },
            ),
          ),

          // Assessment Type Cards
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Choose Assessment Method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4e3f8a),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Assess by Student Card
                  Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: _students.isEmpty
                          ? null
                          : () => _navigateToAssessment('student'),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF4e3f8a),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Assess by Student',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete all assessments for one student',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${_students.length} students',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Assess by Skill Card
                  Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: _students.isEmpty
                          ? null
                          : () => _navigateToAssessment('skill'),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.sports_gymnastics,
                              size: 60,
                              color: Color(0xFF4e3f8a),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Assess by Skill',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Assess one skill for all students',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '6 skills per level',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

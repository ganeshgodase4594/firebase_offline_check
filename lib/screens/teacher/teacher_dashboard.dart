// // lib/screens/teacher/teacher_dashboard.dart
// import 'package:brainmoto_app/screens/teacher/assessmnet_by_student_screen.dart';
// import 'package:brainmoto_app/service/firebase_service.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/connectivity_provider.dart';
// import '../../models/student_model.dart';
// import 'assessment_by_skill_screen.dart';

// class TeacherDashboard extends StatefulWidget {
//   const TeacherDashboard({super.key});

//   @override
//   State<TeacherDashboard> createState() => _TeacherDashboardState();
// }

// class _TeacherDashboardState extends State<TeacherDashboard> {
//   String? _selectedGrade;
//   List<StudentModel> _students = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (authProvider.currentUser?.schoolId != null &&
//         authProvider.currentUser?.assignedGrades != null) {
//       if (authProvider.currentUser!.assignedGrades!.isNotEmpty) {
//         _selectedGrade = authProvider.currentUser!.assignedGrades!.first;
//         await _loadStudents();
//       }
//     }

//     setState(() => _isLoading = false);
//   }

//   Future<void> _loadStudents() async {
//     if (_selectedGrade == null) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final schoolId = authProvider.currentUser!.schoolId!;

//     setState(() => _isLoading = true);

//     // In offline mode, this will load from cache
//     FirebaseService.getStudentsByGradeStream(schoolId, _selectedGrade!)
//         .listen((students) {
//       if (mounted) {
//         setState(() {
//           _students = students;
//           _isLoading = false;
//         });
//       }
//     });
//   }

//   void _navigateToAssessment(String type) {
//     if (type == 'student') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AssessmentByStudentScreen(
//             students: _students,
//             grade: _selectedGrade!,
//           ),
//         ),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AssessmentBySkillScreen(
//             students: _students,
//             grade: _selectedGrade!,
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Teacher Dashboard'),
//         actions: [
//           Consumer<ConnectivityProvider>(
//             builder: (context, connectivity, child) {
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     if (connectivity.pendingSyncCount > 0)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.orange,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           '${connectivity.pendingSyncCount} pending',
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ),
//                     const SizedBox(width: 8),
//                     Icon(
//                       connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
//                       color: connectivity.isOnline ? Colors.white : Colors.red,
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           PopupMenuButton(
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'sync',
//                 child: Row(
//                   children: [
//                     Icon(Icons.sync),
//                     SizedBox(width: 8),
//                     Text('Sync Now'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'settings',
//                 child: Row(
//                   children: [
//                     Icon(Icons.settings),
//                     SizedBox(width: 8),
//                     Text('Settings'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout),
//                     SizedBox(width: 8),
//                     Text('Logout'),
//                   ],
//                 ),
//               ),
//             ],
//             onSelected: (value) async {
//               if (value == 'logout') {
//                 final authProvider =
//                     Provider.of<AuthProvider>(context, listen: false);
//                 await authProvider.signOut();
//                 if (mounted) {
//                   Navigator.of(context).pushReplacementNamed('/login');
//                 }
//               } else if (value == 'sync') {
//                 final connectivity =
//                     Provider.of<ConnectivityProvider>(context, listen: false);
//                 await connectivity.syncPendingData();
//               }
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Connectivity Banner
//           Consumer<ConnectivityProvider>(
//             builder: (context, connectivity, child) {
//               return Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 color: connectivity.isOnline ? Colors.green : Colors.orange,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       connectivity.isOnline
//                           ? Icons.cloud_done
//                           : Icons.cloud_off,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       connectivity.isOnline
//                           ? 'Online - Data Syncing'
//                           : 'Offline Mode - Data Saved Locally',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),

//           // Grade Selector
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Consumer<AuthProvider>(
//               builder: (context, auth, child) {
//                 final grades = auth.currentUser?.assignedGrades ?? [];
//                 if (grades.isEmpty) {
//                   return const Text('No grades assigned');
//                 }

//                 return DropdownButtonFormField<String>(
//                   value: _selectedGrade,
//                   decoration: const InputDecoration(
//                     labelText: 'Select Grade',
//                     prefixIcon: Icon(Icons.class_),
//                   ),
//                   items: grades.map((grade) {
//                     return DropdownMenuItem(
//                       value: grade,
//                       child: Text(grade),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedGrade = value;
//                     });
//                     _loadStudents();
//                   },
//                 );
//               },
//             ),
//           ),

//           // Assessment Type Cards
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Choose Assessment Method',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF4e3f8a),
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Assess by Student Card
//                   Card(
//                     elevation: 4,
//                     child: InkWell(
//                       onTap: _students.isEmpty
//                           ? null
//                           : () => _navigateToAssessment('student'),
//                       child: Container(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           children: [
//                             const Icon(
//                               Icons.person,
//                               size: 60,
//                               color: Color(0xFF4e3f8a),
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Assess by Student',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Complete all assessments for one student',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               '${_students.length} students',
//                               style: TextStyle(
//                                 color: Colors.grey[700],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Assess by Skill Card
//                   Card(
//                     elevation: 4,
//                     child: InkWell(
//                       onTap: _students.isEmpty
//                           ? null
//                           : () => _navigateToAssessment('skill'),
//                       child: Container(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           children: [
//                             const Icon(
//                               Icons.sports_gymnastics,
//                               size: 60,
//                               color: Color(0xFF4e3f8a),
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Assess by Skill',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Assess one skill for all students',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               '6 skills per level',
//                               style: TextStyle(
//                                 color: Colors.grey[700],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/teacher/teacher_dashboard_v2.dart
// import 'package:brainmoto_app/screens/teacher/assessment_by_skill_screen.dart';
// import 'package:brainmoto_app/screens/teacher/assessmnet_by_student_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/connectivity_provider.dart';
// import '../../models/student_model.dart';
// import '../../models/academic_config_model.dart';
// import '../../service/firebase_service.dart';
// import '../../service/firebase_service_extension.dart';

// class TeacherDashboardV2 extends StatefulWidget {
//   const TeacherDashboardV2({super.key});

//   @override
//   State<TeacherDashboardV2> createState() => _TeacherDashboardV2State();
// }

// class _TeacherDashboardV2State extends State<TeacherDashboardV2> {
//   String? _selectedGrade;
//   String? _selectedDivision;
//   List<StudentModel> _students = [];
//   List<String> _availableDivisions = [];
//   bool _isLoading = false;
//   AcademicConfigModel? _academicConfig;
//   bool _isLoadingConfig = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadAcademicConfig();
//   }

//   Future<void> _loadAcademicConfig() async {
//     setState(() => _isLoadingConfig = true);

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (authProvider.currentUser?.schoolId != null) {
//       final config = await FirebaseServiceExtensions.getAcademicConfig(
//         authProvider.currentUser!.schoolId!,
//       );

//       setState(() {
//         _academicConfig = config;
//         _isLoadingConfig = false;
//       });

//       // Auto-select first grade if available
//       if (authProvider.currentUser?.gradeAssignments != null &&
//           authProvider.currentUser!.gradeAssignments!.isNotEmpty) {
//         _selectedGrade = authProvider.currentUser!.gradeAssignments!.keys.first;
//         _updateAvailableDivisions();
//       }
//     } else {
//       setState(() => _isLoadingConfig = false);
//     }
//   }

//   void _updateAvailableDivisions() {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     if (_selectedGrade != null &&
//         authProvider.currentUser?.gradeAssignments != null) {
//       final divisions =
//           authProvider.currentUser!.getDivisionsForGrade(_selectedGrade!);
//       setState(() {
//         _availableDivisions = divisions;
//         // If divisions exist, auto-select first one
//         if (divisions.isNotEmpty) {
//           _selectedDivision = divisions.first;
//         } else {
//           _selectedDivision = null; // Teacher has access to all divisions
//         }
//       });
//       _loadStudents();
//     }
//   }

//   Future<void> _loadStudents() async {
//     if (_selectedGrade == null) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final schoolId = authProvider.currentUser!.schoolId!;

//     setState(() => _isLoading = true);

//     // Load students for selected grade
//     FirebaseService.getStudentsByGradeStream(schoolId, _selectedGrade!)
//         .listen((students) {
//       if (mounted) {
//         // Filter by division if specific division is selected
//         List<StudentModel> filteredStudents = students;

//         if (_selectedDivision != null) {
//           filteredStudents =
//               students.where((s) => s.division == _selectedDivision).toList();
//         } else if (_availableDivisions.isNotEmpty) {
//           // Teacher has specific divisions assigned
//           filteredStudents = students
//               .where((s) => _availableDivisions.contains(s.division))
//               .toList();
//         }
//         // If _availableDivisions is empty, teacher has access to all divisions

//         setState(() {
//           _students = filteredStudents;
//           _isLoading = false;
//         });
//       }
//     });
//   }

//   void _navigateToAssessment(String type) {
//     if (_academicConfig == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//               'No active academic year configured. Please contact coordinator.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (_students.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No students available for assessment'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     if (type == 'student') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AssessmentByStudentScreenV2(
//             students: _students,
//             grade: _selectedGrade!,
//             academicConfig: _academicConfig!,
//           ),
//         ),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AssessmentBySkillScreen(
//             students: _students,
//             grade: _selectedGrade!,
//             academicConfig: _academicConfig!,
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final grades = authProvider.currentUser?.getAllGrades() ?? [];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Teacher Dashboard'),
//         actions: [
//           Consumer<ConnectivityProvider>(
//             builder: (context, connectivity, child) {
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     if (connectivity.pendingSyncCount > 0)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.orange,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           '${connectivity.pendingSyncCount} pending',
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ),
//                     const SizedBox(width: 8),
//                     Icon(
//                       connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
//                       color: connectivity.isOnline ? Colors.white : Colors.red,
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           PopupMenuButton(
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'sync',
//                 child: Row(
//                   children: [
//                     Icon(Icons.sync),
//                     SizedBox(width: 8),
//                     Text('Sync Now'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'settings',
//                 child: Row(
//                   children: [
//                     Icon(Icons.settings),
//                     SizedBox(width: 8),
//                     Text('Settings'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout),
//                     SizedBox(width: 8),
//                     Text('Logout'),
//                   ],
//                 ),
//               ),
//             ],
//             onSelected: (value) async {
//               if (value == 'logout') {
//                 await authProvider.signOut();
//                 if (mounted) {
//                   Navigator.of(context).pushReplacementNamed('/login');
//                 }
//               } else if (value == 'sync') {
//                 final connectivity =
//                     Provider.of<ConnectivityProvider>(context, listen: false);
//                 await connectivity.syncPendingData();
//               }
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Connectivity Banner
//           Consumer<ConnectivityProvider>(
//             builder: (context, connectivity, child) {
//               return Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 color: connectivity.isOnline ? Colors.green : Colors.orange,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       connectivity.isOnline
//                           ? Icons.cloud_done
//                           : Icons.cloud_off,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       connectivity.isOnline
//                           ? 'Online - Data Syncing'
//                           : 'Offline Mode - Data Saved Locally',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),

//           // Academic Year Info
//           if (_isLoadingConfig)
//             const LinearProgressIndicator()
//           else if (_academicConfig != null)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               color: Colors.blue[50],
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.calendar_today,
//                       size: 18, color: Colors.blue),
//                   const SizedBox(width: 8),
//                   Text(
//                     '${_academicConfig!.currentYear} • ${_academicConfig!.currentTerm}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           else
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               color: Colors.red[50],
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.warning, size: 18, color: Colors.red),
//                   SizedBox(width: 8),
//                   Text(
//                     'No active academic year configured',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           // Grade & Division Selectors
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Grade Selector
//                 if (grades.isEmpty)
//                   const Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Text(
//                         'No grades assigned. Please contact coordinator.',
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   )
//                 else
//                   DropdownButtonFormField<String>(
//                     value: _selectedGrade,
//                     decoration: const InputDecoration(
//                       labelText: 'Select Grade',
//                       prefixIcon: Icon(Icons.class_),
//                     ),
//                     items: grades.map((grade) {
//                       return DropdownMenuItem(
//                         value: grade,
//                         child: Text(grade),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedGrade = value;
//                       });
//                       _updateAvailableDivisions();
//                     },
//                   ),

//                 // Division Selector (if teacher has specific divisions)
//                 if (_availableDivisions.isNotEmpty) ...[
//                   const SizedBox(height: 12),
//                   DropdownButtonFormField<String>(
//                     value: _selectedDivision,
//                     decoration: const InputDecoration(
//                       labelText: 'Select Division',
//                       prefixIcon: Icon(Icons.group),
//                     ),
//                     items: _availableDivisions.map((division) {
//                       return DropdownMenuItem(
//                         value: division,
//                         child: Text(division),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedDivision = value;
//                       });
//                       _loadStudents();
//                     },
//                   ),
//                 ],
//               ],
//             ),
//           ),

//           // Student Count
//           if (_selectedGrade != null)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 color: Colors.green[50],
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.people, color: Colors.green),
//                       const SizedBox(width: 8),
//                       Text(
//                         '${_students.length} students available',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // Assessment Type Cards
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Choose Assessment Method',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF4e3f8a),
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Assess by Student Card
//                   Card(
//                     elevation: 4,
//                     child: InkWell(
//                       onTap: _students.isEmpty || _academicConfig == null
//                           ? null
//                           : () => _navigateToAssessment('student'),
//                       child: Container(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.person,
//                               size: 60,
//                               color:
//                                   _students.isEmpty || _academicConfig == null
//                                       ? Colors.grey
//                                       : const Color(0xFF4e3f8a),
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Assess by Student',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Complete all assessments for one student',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               '${_students.length} students',
//                               style: TextStyle(
//                                 color: Colors.grey[700],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Assess by Skill Card
//                   Card(
//                     elevation: 4,
//                     child: InkWell(
//                       onTap: _students.isEmpty || _academicConfig == null
//                           ? null
//                           : () => _navigateToAssessment('skill'),
//                       child: Container(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.sports_gymnastics,
//                               size: 60,
//                               color:
//                                   _students.isEmpty || _academicConfig == null
//                                       ? Colors.grey
//                                       : const Color(0xFF4e3f8a),
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Assess by Skill',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Assess one skill for all students',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               '6 skills per level',
//                               style: TextStyle(
//                                 color: Colors.grey[700],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/teacher/teacher_dashboard_refactored.dart
import 'package:brainmoto_app/screens/teacher/assessment_by_skill_screen.dart';
import 'package:brainmoto_app/screens/teacher/assessmnet_by_student_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/school_provider.dart';

class TeacherDashboardRefactored extends StatelessWidget {
  const TeacherDashboardRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = StudentProvider();
            final authProvider = context.read<AuthProvider>();
            if (authProvider.currentUser?.schoolId != null) {
              provider
                  .loadStudentsBySchool(authProvider.currentUser!.schoolId!);
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = SchoolProvider();
            final authProvider = context.read<AuthProvider>();
            if (authProvider.currentUser?.schoolId != null) {
              provider.loadAcademicConfig(authProvider.currentUser!.schoolId!);
            }
            return provider;
          },
        ),
      ],
      child: const _TeacherDashboardContent(),
    );
  }
}

class _TeacherDashboardContent extends StatelessWidget {
  const _TeacherDashboardContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          _buildSyncStatus(),
          _buildMenuButton(context),
        ],
      ),
      body: Column(
        children: [
          _buildConnectivityBanner(),
          _buildAcademicYearInfo(),
          _buildGradeDivisionSelector(),
          _buildStudentCount(),
          Expanded(child: _buildAssessmentCards()),
        ],
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (connectivity.pendingSyncCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return PopupMenuButton(
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
          final authProvider = context.read<AuthProvider>();
          await authProvider.signOut();
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else if (value == 'sync') {
          final connectivity = context.read<ConnectivityProvider>();
          await connectivity.syncPendingData();
        }
      },
    );
  }

  Widget _buildConnectivityBanner() {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: connectivity.isOnline ? Colors.green : Colors.orange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                connectivity.isOnline ? Icons.cloud_done : Icons.cloud_off,
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
    );
  }

  Widget _buildAcademicYearInfo() {
    return Consumer<SchoolProvider>(
      builder: (context, schoolProvider, child) {
        if (schoolProvider.isLoadingConfig) {
          return const LinearProgressIndicator();
        }

        final config = schoolProvider.academicConfig;

        if (config == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.red[50],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'No active academic year configured',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '${config.currentYear} • ${config.currentTerm}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradeDivisionSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Consumer2<AuthProvider, StudentProvider>(
        builder: (context, auth, studentProvider, child) {
          final grades = auth.currentUser?.getAllGrades() ?? [];

          if (grades.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No grades assigned. Please contact coordinator.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return Column(
            children: [
              DropdownButtonFormField<String>(
                value: studentProvider.selectedGrade,
                decoration: const InputDecoration(
                  labelText: 'Select Grade',
                  prefixIcon: Icon(Icons.class_),
                ),
                items: grades.map((grade) {
                  return DropdownMenuItem(value: grade, child: Text(grade));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final schoolId = auth.currentUser!.schoolId!;
                    studentProvider.setGradeFilter(value);
                    studentProvider.loadStudentsByGrade(schoolId, value);
                  }
                },
              ),
              if (studentProvider.availableDivisions.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: studentProvider.selectedDivision,
                  decoration: const InputDecoration(
                    labelText: 'Select Division',
                    prefixIcon: Icon(Icons.group),
                  ),
                  items: studentProvider.availableDivisions.map((division) {
                    return DropdownMenuItem(
                      value: division,
                      child: Text(division),
                    );
                  }).toList(),
                  onChanged: (value) {
                    studentProvider.setDivisionFilter(value);
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentCount() {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (provider.selectedGrade == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.filteredStudents.length} students available',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssessmentCards() {
    return Padding(
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
          _buildAssessmentCard(
            title: 'Assess by Student',
            subtitle: 'Complete all assessments for one student',
            icon: Icons.person,
            info: '6 skills per level',
            onTap: (context) => _navigateToAssessment(context, 'student'),
          ),
          const SizedBox(height: 20),
          _buildAssessmentCard(
            title: 'Assess by Skill',
            subtitle: 'Assess one skill for all students',
            icon: Icons.sports_gymnastics,
            info: 'All students at once',
            onTap: (context) => _navigateToAssessment(context, 'skill'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String info,
    required Function(BuildContext) onTap,
  }) {
    return Consumer2<StudentProvider, SchoolProvider>(
      builder: (context, studentProvider, schoolProvider, child) {
        final isEnabled = studentProvider.filteredStudents.isNotEmpty &&
            schoolProvider.academicConfig != null;

        return Card(
          elevation: 4,
          child: InkWell(
            onTap: isEnabled ? () => onTap(context) : null,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    icon,
                    size: 60,
                    color: isEnabled ? const Color(0xFF4e3f8a) : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    info,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToAssessment(BuildContext context, String type) {
    final studentProvider = context.read<StudentProvider>();
    final schoolProvider = context.read<SchoolProvider>();

    if (schoolProvider.academicConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No active academic year configured. Please contact coordinator.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final students = studentProvider.filteredStudents;
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students available for assessment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (type == 'student') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentByStudentScreenRefactored(
            students: students,
            grade: studentProvider.selectedGrade!,
            academicConfig: schoolProvider.academicConfig!,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentBySkillScreenRefactored(
            students: students,
            grade: studentProvider.selectedGrade!,
            academicConfig: schoolProvider.academicConfig!,
          ),
        ),
      );
    }
  }
}

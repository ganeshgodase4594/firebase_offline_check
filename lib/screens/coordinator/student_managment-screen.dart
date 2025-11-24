// lib/screens/coordinator/student_management_screen.dart
import 'package:flutter/material.dart';
import '../../models/school_model.dart';
import '../../models/student_model.dart';
import '../../service/firebase_service.dart';

class StudentManagementScreen extends StatefulWidget {
  final SchoolModel school;

  const StudentManagementScreen({super.key, required this.school});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  String? _selectedGrade;
  String? _selectedDivision;
  List<StudentModel> _students = [];
  List<StudentModel> _filteredStudents = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStudents() {
    FirebaseService.getStudentsBySchoolStream(widget.school.id)
        .listen((students) {
      if (mounted) {
        setState(() {
          _students = students;
          _applyFilters();
          _isLoading = false;
        });
      }
    });
  }

  void _applyFilters() {
    var filtered = _students;

    // Filter by grade
    if (_selectedGrade != null) {
      filtered = filtered.where((s) => s.grade == _selectedGrade).toList();
    }

    // Filter by division
    if (_selectedDivision != null) {
      filtered =
          filtered.where((s) => s.division == _selectedDivision).toList();
    }

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final search = _searchController.text.toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(search) ||
            s.uid.toLowerCase().contains(search);
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _filteredStudents = filtered;
    });
  }

  List<String> _getUniqueGrades() {
    return _students.map((s) => s.grade).toSet().toList()..sort();
  }

  List<String> _getUniqueDivisions() {
    if (_selectedGrade == null) return [];
    return _students
        .where((s) => s.grade == _selectedGrade)
        .map((s) => s.division)
        .toSet()
        .toList()
      ..sort();
  }

  void _showAddStudentDialog() async {
    final result = await showDialog<StudentModel>(
      context: context,
      builder: (context) => AddStudentDialog(school: widget.school),
    );

    if (result != null) {
      try {
        await FirebaseService.createStudent(result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showEditStudentDialog(StudentModel student) async {
    final result = await showDialog<StudentModel>(
      context: context,
      builder: (context) => EditStudentDialog(
        school: widget.school,
        student: student,
      ),
    );

    if (result != null) {
      try {
        await FirebaseService.updateStudent(student.id, result.toFirestore());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _toggleAbsentStatus(StudentModel student) async {
    try {
      await FirebaseService.markStudentAbsent(student.id, !student.isAbsent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(student.isAbsent
                ? 'Student marked as present'
                : 'Student marked as absent'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _markStudentLeftSchool(StudentModel student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Student as Left School'),
        content: Text(
          'Are you sure ${student.name} has left the school?\n\n'
          'This will deactivate the student record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Mark as Left'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseService.markStudentLeftSchool(student.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student marked as left school'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniqueGrades = _getUniqueGrades();
    final uniqueDivisions = _getUniqueDivisions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddStudentDialog,
            tooltip: 'Add Student',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or UID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
                const SizedBox(height: 12),
                // Grade and Division filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        decoration: const InputDecoration(
                          labelText: 'Grade',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Grades')),
                          ...uniqueGrades.map((grade) => DropdownMenuItem(
                                value: grade,
                                child: Text(grade),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGrade = value;
                            _selectedDivision = null;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDivision,
                        decoration: const InputDecoration(
                          labelText: 'Division',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Divisions')),
                          ...uniqueDivisions.map((div) => DropdownMenuItem(
                                value: div,
                                child: Text(div),
                              )),
                        ],
                        onChanged: _selectedGrade == null
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedDivision = value;
                                  _applyFilters();
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_filteredStudents.length} of ${_students.length} students',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (_selectedGrade != null || _searchController.text.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedGrade = null;
                        _selectedDivision = null;
                        _searchController.clear();
                        _applyFilters();
                      });
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear Filters',
                        style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No students found',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: student.isAbsent
                                    ? Colors.orange
                                    : const Color(0xFF4e3f8a),
                                child: Text(
                                  student.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(child: Text(student.name)),
                                  if (student.isAbsent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ABSENT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                'UID: ${student.uid}\n'
                                '${student.grade} - ${student.division} | Level ${student.level}',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _showEditStudentDialog(student);
                                      break;
                                    case 'absent':
                                      _toggleAbsentStatus(student);
                                      break;
                                    case 'left':
                                      _markStudentLeftSchool(student);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Edit Details'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'absent',
                                    child: Row(
                                      children: [
                                        Icon(student.isAbsent
                                            ? Icons.check_circle
                                            : Icons.person_off),
                                        const SizedBox(width: 8),
                                        Text(student.isAbsent
                                            ? 'Mark Present'
                                            : 'Mark Absent'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'left',
                                    child: Row(
                                      children: [
                                        Icon(Icons.exit_to_app,
                                            color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Left School',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
    );
  }
}

// ============================================
// ADD STUDENT DIALOG
// ============================================

class AddStudentDialog extends StatefulWidget {
  final SchoolModel school;

  const AddStudentDialog({Key? key, required this.school}) : super(key: key);

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uidController = TextEditingController();
  String? _selectedGrade;
  final _divisionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _uidController.dispose();
    _divisionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grades = widget.school.gradeToLevelMap.keys.toList()..sort();

    return AlertDialog(
      title: const Text('Add New Student'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _uidController,
                decoration: InputDecoration(
                  labelText: 'UID *',
                  hintText: '${widget.school.code}001',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: const InputDecoration(labelText: 'Grade *'),
                items: grades.map((grade) {
                  final level = widget.school.gradeToLevelMap[grade];
                  return DropdownMenuItem(
                    value: grade,
                    child: Text('$grade (Level $level)'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGrade = value);
                },
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _divisionController,
                decoration: const InputDecoration(
                  labelText: 'Division *',
                  hintText: 'A, B, Rigel, etc.',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final level = widget.school.gradeToLevelMap[_selectedGrade] ?? 1;
              final student = StudentModel(
                id: '',
                uid: _uidController.text.trim(),
                name: _nameController.text.trim(),
                schoolId: widget.school.id,
                grade: _selectedGrade!,
                division: _divisionController.text.trim(),
                level: level,
                createdAt: DateTime.now(),
              );
              Navigator.pop(context, student);
            }
          },
          child: const Text('Add Student'),
        ),
      ],
    );
  }
}

// ============================================
// EDIT STUDENT DIALOG
// ============================================

class EditStudentDialog extends StatefulWidget {
  final SchoolModel school;
  final StudentModel student;

  const EditStudentDialog({
    Key? key,
    required this.school,
    required this.student,
  }) : super(key: key);

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedGrade;
  final _divisionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.student.name;
    _selectedGrade = widget.student.grade;
    _divisionController.text = widget.student.division;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _divisionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grades = widget.school.gradeToLevelMap.keys.toList()..sort();

    return AlertDialog(
      title: const Text('Edit Student'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.student.uid,
                decoration: const InputDecoration(labelText: 'UID'),
                enabled: false,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: const InputDecoration(labelText: 'Grade *'),
                items: grades.map((grade) {
                  final level = widget.school.gradeToLevelMap[grade];
                  return DropdownMenuItem(
                    value: grade,
                    child: Text('$grade (Level $level)'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGrade = value);
                },
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _divisionController,
                decoration: const InputDecoration(labelText: 'Division *'),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final level = widget.school.gradeToLevelMap[_selectedGrade] ?? 1;
              final updatedStudent = StudentModel(
                id: widget.student.id,
                uid: widget.student.uid,
                name: _nameController.text.trim(),
                schoolId: widget.student.schoolId,
                grade: _selectedGrade!,
                division: _divisionController.text.trim(),
                level: level,
                isActive: widget.student.isActive,
                isAbsent: widget.student.isAbsent,
                createdAt: widget.student.createdAt,
              );
              Navigator.pop(context, updatedStudent);
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

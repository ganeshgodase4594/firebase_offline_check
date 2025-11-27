// lib/screens/coordinator/student_management_screen_refactored.dart
import 'package:brainmoto_app/widgets/error_dailog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coordinator_provider.dart';
import '../../models/student_model.dart';

class StudentManagementScreenRefactored extends StatelessWidget {
  const StudentManagementScreenRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddStudentDialog(context),
            tooltip: 'Add Student',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildStats(),
          Expanded(child: _buildStudentList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
    );
  }

  Widget _buildFilters() {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              // Search
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or UID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => provider.setSearchQuery(''),
                        )
                      : null,
                ),
                onChanged: (value) => provider.setSearchQuery(value),
              ),
              const SizedBox(height: 12),
              // Grade and Division filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: provider.selectedGrade,
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Grades')),
                        ...provider.availableGrades.map((grade) =>
                            DropdownMenuItem(value: grade, child: Text(grade))),
                      ],
                      onChanged: (value) => provider.setGradeFilter(value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: provider.selectedDivision,
                      decoration: const InputDecoration(
                        labelText: 'Division',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Divisions')),
                        ...provider.availableDivisions.map((div) =>
                            DropdownMenuItem(value: div, child: Text(div))),
                      ],
                      onChanged: provider.selectedGrade == null
                          ? null
                          : (value) => provider.setDivisionFilter(value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats() {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        final filtered = provider.filteredStudents;
        final total = provider.students;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${filtered.length} of ${total.length} students',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (provider.selectedGrade != null ||
                  provider.searchQuery.isNotEmpty)
                TextButton.icon(
                  onPressed: () => provider.clearFilters(),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Filters',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentList() {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    if (provider.selectedSchool != null) {
                      provider.loadStudents(provider.selectedSchool!.id);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final students = provider.filteredStudents;

        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No students found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return _buildStudentCard(context, student, provider);
          },
        );
      },
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    StudentModel student,
    CoordinatorProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              student.isAbsent ? Colors.orange : const Color(0xFF4e3f8a),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          'UID: ${student.uid}\n${student.grade} - ${student.division} | Level ${student.level}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleStudentAction(context, value, student, provider),
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
                  Icon(
                      student.isAbsent ? Icons.check_circle : Icons.person_off),
                  const SizedBox(width: 8),
                  Text(student.isAbsent ? 'Mark Present' : 'Mark Absent'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'left',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Left School', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStudentAction(
    BuildContext context,
    String action,
    StudentModel student,
    CoordinatorProvider provider,
  ) async {
    switch (action) {
      case 'edit':
        _showEditStudentDialog(context, student, provider);
        break;
      case 'absent':
        try {
          await provider.markStudentAbsent(student.id, !student.isAbsent);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(student.isAbsent
                    ? 'Student marked as present'
                    : 'Student marked as absent'),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        }
        break;
      case 'left':
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
            await provider.markStudentLeftSchool(student.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Student marked as left school')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error: $e'), backgroundColor: Colors.red),
              );
            }
          }
        }
        break;
    }
  }

  void _showAddStudentDialog(BuildContext context) {
    final provider = Provider.of<CoordinatorProvider>(context, listen: false);

    if (provider.selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No school selected')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AddStudentDialog(),
    );
  }

  void _showEditStudentDialog(
    BuildContext context,
    StudentModel student,
    CoordinatorProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EditStudentDialog(student: student),
    );
  }
}

// Add Student Dialog
class _AddStudentDialog extends StatefulWidget {
  @override
  State<_AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<_AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uidController = TextEditingController();
  String? _selectedGrade;
  String? _selectedDivision;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        final school = provider.selectedSchool!;
        final grades = school.gradeToLevelMap.keys.toList()..sort();

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
                    decoration: const InputDecoration(labelText: 'Name *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _uidController,
                    decoration: const InputDecoration(labelText: 'UID *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(labelText: 'Grade *'),
                    items: grades
                        .map((grade) =>
                            DropdownMenuItem(value: grade, child: Text(grade)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGrade = value;
                        _selectedDivision = null;
                      });
                    },
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  TextFormField(
                    onChanged: (value) => _selectedDivision = value,
                    decoration: const InputDecoration(labelText: 'Division *'),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                final level = school.gradeToLevelMap[_selectedGrade] ?? 1;
                final existingUIds =
                    provider.students.map((s) => s.uid.toLowerCase()).toSet();

                final uid = _uidController.text.trim().toLowerCase();

                // Check for duplicate UID (exclude current student if editing)
                if (existingUIds.contains(uid)) {
                  ErrorDialog.show(
                    context,
                    message: 'UID "$uid" already exists in the database',
                    title: 'Duplicate UID',
                  );
                  return;
                }

                final student = StudentModel(
                  id: '',
                  uid: uid,
                  name: _nameController.text.trim(),
                  schoolId: school.id,
                  grade: _selectedGrade!,
                  division: _selectedDivision!,
                  level: level,
                  createdAt: DateTime.now(),
                );

                try {
                  await provider.createStudent(student);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Student added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// Edit Student Dialog
class _EditStudentDialog extends StatefulWidget {
  final StudentModel student;

  const _EditStudentDialog({required this.student});

  @override
  State<_EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<_EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedGrade;
  late String _selectedDivision;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _selectedGrade = widget.student.grade;
    _selectedDivision = widget.student.division;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        final school = provider.selectedSchool!;
        final grades = school.gradeToLevelMap.keys.toList()..sort();

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
                    decoration: const InputDecoration(labelText: 'Name *'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Text('UID: ${widget.student.uid}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration: const InputDecoration(labelText: 'Grade *'),
                    items: grades
                        .map((grade) =>
                            DropdownMenuItem(value: grade, child: Text(grade)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedGrade = value!);
                    },
                  ),
                  TextFormField(
                    initialValue: _selectedDivision,
                    onChanged: (value) => _selectedDivision = value,
                    decoration: const InputDecoration(labelText: 'Division *'),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                final level = school.gradeToLevelMap[_selectedGrade] ?? 1;

                try {
                  await provider.updateStudent(widget.student.id, {
                    'name': _nameController.text.trim(),
                    'grade': _selectedGrade,
                    'division': _selectedDivision,
                    'level': level,
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Student updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

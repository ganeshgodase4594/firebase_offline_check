// lib/screens/coordinator/add_teacher_screen_refactored.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coordinator_provider.dart';
import '../../models/user_model.dart';
import '../../service/firebase_service.dart';

class AddTeacherScreenRefactored extends StatefulWidget {
  const AddTeacherScreenRefactored({super.key});

  @override
  State<AddTeacherScreenRefactored> createState() =>
      _AddTeacherScreenRefactoredState();
}

class _AddTeacherScreenRefactoredState
    extends State<AddTeacherScreenRefactored> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Map<String, List<String>> _gradeAssignments = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showGradeAssignmentDialog(BuildContext context) {
    final provider = Provider.of<CoordinatorProvider>(context, listen: false);
    final grades = provider.availableGrades;

    showDialog(
      context: context,
      builder: (context) => _GradeAssignmentDialog(
        availableGrades: grades,
        currentAssignments: Map.from(_gradeAssignments),
        onSave: (assignments) {
          setState(() => _gradeAssignments = assignments);
        },
      ),
    );
  }

  Future<void> _createTeacher(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_gradeAssignments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please assign at least one grade'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<CoordinatorProvider>(context, listen: false);
    final school = provider.selectedSchool!;

    try {
      final userCredential = await FirebaseService.createUserWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        role: UserRole.teacher,
        schoolId: school.id,
        gradeAssignments: _gradeAssignments,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        createdAt: DateTime.now(),
        isActive: true,
      );

      await provider.createTeacher(user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teacher created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        final school = provider.selectedSchool;

        if (school == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Add Teacher')),
            body: const Center(child: Text('No school selected')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Add Teacher')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name *'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration:
                      const InputDecoration(labelText: 'Phone (optional)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password *'),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    title: const Text('Grade & Division Assignments'),
                    subtitle: Text(
                      _gradeAssignments.isEmpty
                          ? 'Tap to assign grades'
                          : _formatAssignments(),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showGradeAssignmentDialog(context),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _createTeacher(context),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Teacher'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatAssignments() {
    final parts = <String>[];
    _gradeAssignments.forEach((grade, divisions) {
      if (divisions.isEmpty) {
        parts.add(grade);
      } else {
        parts.add('$grade (${divisions.join(", ")})');
      }
    });
    return parts.join('; ');
  }
}

// Grade Assignment Dialog
class _GradeAssignmentDialog extends StatefulWidget {
  final List<String> availableGrades;
  final Map<String, List<String>> currentAssignments;
  final Function(Map<String, List<String>>) onSave;

  const _GradeAssignmentDialog({
    required this.availableGrades,
    required this.currentAssignments,
    required this.onSave,
  });

  @override
  State<_GradeAssignmentDialog> createState() => _GradeAssignmentDialogState();
}

class _GradeAssignmentDialogState extends State<_GradeAssignmentDialog> {
  late Map<String, List<String>> _tempAssignments;
  final _divisionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempAssignments = Map.from(widget.currentAssignments);
  }

  @override
  void dispose() {
    _divisionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Grades & Divisions'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select grades to assign:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.availableGrades.map((grade) {
                final isSelected = _tempAssignments.containsKey(grade);
                return FilterChip(
                  label: Text(grade),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tempAssignments[grade] = [];
                      } else {
                        _tempAssignments.remove(grade);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Divisions (leave empty for all divisions):'),
            const SizedBox(height: 8),
            Expanded(
              child: _tempAssignments.isEmpty
                  ? const Center(child: Text('No grades selected'))
                  : ListView(
                      children: _tempAssignments.entries.map((entry) {
                        return Card(
                          child: ListTile(
                            title: Text(entry.key),
                            subtitle: Text(
                              entry.value.isEmpty
                                  ? 'All divisions'
                                  : entry.value.join(', '),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _addDivision(entry.key),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_tempAssignments);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _addDivision(String grade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Division for $grade'),
        content: TextField(
          controller: _divisionController,
          decoration: const InputDecoration(
            labelText: 'Division Name',
            hintText: 'e.g., A, B, Rigel',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _divisionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final division = _divisionController.text.trim();
              if (division.isNotEmpty &&
                  !_tempAssignments[grade]!.contains(division)) {
                setState(() => _tempAssignments[grade]!.add(division));
              }
              _divisionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

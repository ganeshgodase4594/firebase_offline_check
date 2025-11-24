import 'package:brainmoto_app/models/school_model.dart';
import 'package:brainmoto_app/models/user_model.dart';
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:flutter/material.dart';

class AddTeacherScreen extends StatefulWidget {
  final SchoolModel school;

  const AddTeacherScreen({Key? key, required this.school}) : super(key: key);

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
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

  void _showGradeAssignmentDialog() async {
    final grades = widget.school.gradeToLevelMap.keys.toList();

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

  Future<void> _createTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gradeAssignments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please assign at least one grade'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

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
        schoolId: widget.school.id,
        gradeAssignments: _gradeAssignments,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        createdAt: DateTime.now(),
        isActive: true,
      );

      await FirebaseService.createUser(user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Teacher created successfully!'),
              backgroundColor: Colors.green),
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
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
                onTap: _showGradeAssignmentDialog,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTeacher,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Create Teacher'),
            ),
          ],
        ),
      ),
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

// ============================================
// GRADE ASSIGNMENT DIALOG
// ============================================

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

  void _addGrade(String grade) {
    if (!_tempAssignments.containsKey(grade)) {
      setState(() => _tempAssignments[grade] = []);
    }
  }

  void _removeGrade(String grade) {
    setState(() => _tempAssignments.remove(grade));
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

  void _removeDivision(String grade, String division) {
    setState(() => _tempAssignments[grade]!.remove(division));
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
                    if (selected) {
                      _addGrade(grade);
                    } else {
                      _removeGrade(grade);
                    }
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
                          child: ExpansionTile(
                            title: Text(entry.key),
                            subtitle: Text(
                              entry.value.isEmpty
                                  ? 'All divisions'
                                  : entry.value.join(', '),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    ...entry.value.map((div) => Chip(
                                          label: Text(div),
                                          onDeleted: () =>
                                              _removeDivision(entry.key, div),
                                        )),
                                    ActionChip(
                                      label: const Text('+ Add Division'),
                                      onPressed: () => _addDivision(entry.key),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
}

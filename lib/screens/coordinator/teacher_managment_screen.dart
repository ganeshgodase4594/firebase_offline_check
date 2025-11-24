// lib/screens/coordinator/teacher_management_screen.dart
import 'package:flutter/material.dart';
import '../../models/school_model.dart';
import '../../models/user_model.dart';
import '../../service/firebase_service.dart';

class TeacherManagementScreen extends StatefulWidget {
  final SchoolModel school;

  const TeacherManagementScreen({Key? key, required this.school})
      : super(key: key);

  @override
  State<TeacherManagementScreen> createState() =>
      _TeacherManagementScreenState();
}

class _TeacherManagementScreenState extends State<TeacherManagementScreen> {
  List<UserModel> _teachers = [];
  List<UserModel> _filteredTeachers = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  String? _selectedGrade;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTeachers() {
    FirebaseService.getTeachersBySchoolStream(widget.school.id)
        .listen((teachers) {
      if (mounted) {
        setState(() {
          _teachers = teachers;
          _applyFilters();
          _isLoading = false;
        });
      }
    });
  }

  void _applyFilters() {
    var filtered = _teachers;

    // Filter by grade
    if (_selectedGrade != null) {
      filtered = filtered.where((t) {
        if (t.gradeAssignments == null) return false;
        return t.gradeAssignments!.containsKey(_selectedGrade);
      }).toList();
    }

    // Search filter
    if (_searchController.text.isNotEmpty) {
      final search = _searchController.text.toLowerCase();
      filtered = filtered.where((t) {
        return t.name.toLowerCase().contains(search) ||
            t.email.toLowerCase().contains(search);
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _filteredTeachers = filtered;
    });
  }

  List<String> _getAssignedGrades() {
    final grades = <String>{};
    for (var teacher in _teachers) {
      if (teacher.gradeAssignments != null) {
        grades.addAll(teacher.gradeAssignments!.keys);
      }
    }
    return grades.toList()..sort();
  }

  void _showEditTeacherDialog(UserModel teacher) async {
    final result = await showDialog<Map<String, List<String>>>(
      context: context,
      builder: (context) => EditTeacherAssignmentsDialog(
        school: widget.school,
        teacher: teacher,
      ),
    );

    if (result != null) {
      try {
        await FirebaseService.updateUser(teacher.uid, {
          'gradeAssignments': result,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teacher assignments updated successfully!'),
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

  void _deactivateTeacher(UserModel teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Teacher'),
        content: Text(
          'Are you sure you want to deactivate ${teacher.name}?\n\n'
          'They will no longer be able to log in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseService.updateUser(teacher.uid, {'isActive': false});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teacher deactivated'),
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

  void _reactivateTeacher(UserModel teacher) async {
    try {
      await FirebaseService.updateUser(teacher.uid, {'isActive': true});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teacher reactivated'),
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

  @override
  Widget build(BuildContext context) {
    final assignedGrades = _getAssignedGrades();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Management'),
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or email',
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
                DropdownButtonFormField<String>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Grade',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Grades')),
                    ...assignedGrades.map((grade) => DropdownMenuItem(
                          value: grade,
                          child: Text(grade),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGrade = value;
                      _applyFilters();
                    });
                  },
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
                  'Showing ${_filteredTeachers.length} of ${_teachers.length} teachers',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (_selectedGrade != null || _searchController.text.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedGrade = null;
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

          // Teacher List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTeachers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No teachers found',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTeachers.length,
                        itemBuilder: (context, index) {
                          final teacher = _filteredTeachers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: teacher.isActive
                                    ? const Color(0xFF4e3f8a)
                                    : Colors.grey,
                                child: Text(
                                  teacher.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(child: Text(teacher.name)),
                                  if (!teacher.isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'INACTIVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(teacher.email),
                                  if (teacher.phoneNumber != null)
                                    Text('Phone: ${teacher.phoneNumber}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _showEditTeacherDialog(teacher);
                                      break;
                                    case 'deactivate':
                                      _deactivateTeacher(teacher);
                                      break;
                                    case 'reactivate':
                                      _reactivateTeacher(teacher);
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
                                        Text('Edit Assignments'),
                                      ],
                                    ),
                                  ),
                                  if (teacher.isActive)
                                    const PopupMenuItem(
                                      value: 'deactivate',
                                      child: Row(
                                        children: [
                                          Icon(Icons.block, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Deactivate',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    )
                                  else
                                    const PopupMenuItem(
                                      value: 'reactivate',
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Reactivate',
                                              style: TextStyle(
                                                  color: Colors.green)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border(
                                      top: BorderSide(color: Colors.grey[300]!),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Assigned Grades & Divisions:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (teacher.gradeAssignments == null ||
                                          teacher.gradeAssignments!.isEmpty)
                                        const Text('No assignments',
                                            style:
                                                TextStyle(color: Colors.grey))
                                      else
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: teacher
                                              .gradeAssignments!.entries
                                              .map((entry) {
                                            final grade = entry.key;
                                            final divisions = entry.value;
                                            return Chip(
                                              label: Text(
                                                divisions.isEmpty
                                                    ? grade
                                                    : '$grade (${divisions.join(", ")})',
                                              ),
                                              backgroundColor:
                                                  const Color(0xFF4e3f8a)
                                                      .withOpacity(0.1),
                                            );
                                          }).toList(),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// EDIT TEACHER ASSIGNMENTS DIALOG
// ============================================

class EditTeacherAssignmentsDialog extends StatefulWidget {
  final SchoolModel school;
  final UserModel teacher;

  const EditTeacherAssignmentsDialog({
    Key? key,
    required this.school,
    required this.teacher,
  }) : super(key: key);

  @override
  State<EditTeacherAssignmentsDialog> createState() =>
      _EditTeacherAssignmentsDialogState();
}

class _EditTeacherAssignmentsDialogState
    extends State<EditTeacherAssignmentsDialog> {
  late Map<String, List<String>> _tempAssignments;
  final _divisionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempAssignments = widget.teacher.gradeAssignments != null
        ? Map.from(widget.teacher.gradeAssignments!)
        : {};
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
    final availableGrades = widget.school.gradeToLevelMap.keys.toList()..sort();

    return AlertDialog(
      title: Text('Edit Assignments - ${widget.teacher.name}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${widget.teacher.email}'),
                    if (widget.teacher.phoneNumber != null)
                      Text('Phone: ${widget.teacher.phoneNumber}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select grades to assign:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: availableGrades.map((grade) {
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
            const Text(
              'Divisions (leave empty for all):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            Navigator.pop(context, _tempAssignments);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

// lib/screens/coordinator/grade_remapping_screen_refactored.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coordinator_provider.dart';
import '../../service/firebase_service.dart';
import '../../service/firebase_service_extension.dart';

class GradeRemappingScreenRefactored extends StatefulWidget {
  const GradeRemappingScreenRefactored({super.key});

  @override
  State<GradeRemappingScreenRefactored> createState() =>
      _GradeRemappingScreenRefactoredState();
}

class _GradeRemappingScreenRefactoredState
    extends State<GradeRemappingScreenRefactored> {
  late Map<String, int> _localMapping;
  List<String>? _actualGrades;
  bool _hasChanges = false;
  bool _isLoadingGrades = false;
  final _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeMapping();
  }

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  void _initializeMapping() async {
    final provider = Provider.of<CoordinatorProvider>(context, listen: false);
    final school = provider.selectedSchool;

    if (school == null) return;

    setState(() {
      _isLoadingGrades = true;
    });

    try {
      // CRITICAL FIX: Fetch fresh school data from Firestore
      final freshSchool = await FirebaseService.getSchool(school.id);

      if (freshSchool == null) {
        throw Exception('Could not load school data');
      }

      // Use fresh mapping from Firestore
      _localMapping = Map.from(freshSchool.gradeToLevelMap);

      final grades =
          await FirebaseServiceExtensions.getUniqueGradesFromSchool(school.id);

      setState(() {
        _actualGrades = grades.cast<String>();
        _isLoadingGrades = false;

        // Add any new grades not in mapping with default level 1
        for (var grade in grades) {
          if (!_localMapping.containsKey(grade)) {
            _localMapping[grade!] = 1;
          }
        }
      });
    } catch (e) {
      setState(() => _isLoadingGrades = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading grades: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateMapping(String grade, int level) {
    setState(() {
      _localMapping[grade] = level;
      _hasChanges = true;
    });
  }

  // NEW: Check if a level is already used by another grade
  bool _isLevelUsed(int level, String currentGrade) {
    return _localMapping.entries.any(
      (entry) => entry.key != currentGrade && entry.value == level,
    );
  }

  void _addCustomGrade() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedLevel = 1;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Custom Grade'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _gradeController,
                    decoration: const InputDecoration(
                      labelText: 'Grade Name',
                      hintText: 'e.g., Pre-Nursery',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'Brainmoto Level',
                    ),
                    items: List.generate(8, (i) => i + 1)
                        .map((level) => DropdownMenuItem(
                              value: level,
                              // Disable if level is already used
                              enabled: !_isLevelUsed(level, ''),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Level $level',
                                    style: TextStyle(
                                      color: _isLevelUsed(level, '')
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                  if (_isLevelUsed(level, ''))
                                    const Icon(Icons.block,
                                        size: 16, color: Colors.red),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null && !_isLevelUsed(value, '')) {
                        setDialogState(() => selectedLevel = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _gradeController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final gradeName = _gradeController.text.trim();
                    if (gradeName.isNotEmpty) {
                      if (_localMapping.containsKey(gradeName)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('This grade already exists!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _localMapping[gradeName] = selectedLevel;
                        _hasChanges = true;
                      });
                      _gradeController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeGrade(String grade) {
    final isUsedByStudents = _actualGrades?.contains(grade) ?? false;

    if (isUsedByStudents) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Remove Grade'),
          content: Text(
            'The grade "$grade" is currently assigned to students and cannot be removed.\n\n'
            'You can only change its level mapping.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Grade'),
        content: Text('Remove "$grade" from grade mapping?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _localMapping.remove(grade);
                _hasChanges = true;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMapping() async {
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Grade Mapping'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. Update the school\'s grade-level mapping'),
            const Text('2. Update all student levels based on their grades'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This affects all students in the mapped grades',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save & Update Students'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = Provider.of<CoordinatorProvider>(context, listen: false);

    try {
      await provider.updateGradeMapping(_localMapping);

      setState(() => _hasChanges = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Mapping Saved'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grade mapping updated successfully!'),
                SizedBox(height: 16),
                Text('✓ School mapping saved'),
                Text('✓ Student levels updated'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mapping: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                'You have unsaved changes. Are you sure you want to leave?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Stay'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Discard Changes'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Consumer<CoordinatorProvider>(
        builder: (context, provider, child) {
          final school = provider.selectedSchool;

          if (school == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Grade-Level Mapping')),
              body: const Center(child: Text('No school selected')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Grade-Level Mapping'),
              actions: [
                if (_hasChanges)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'UNSAVED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: provider.isLoading || _isLoadingGrades
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Info Card
                      Card(
                        margin: const EdgeInsets.all(16),
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'School: ${school.name}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Map school-specific grade names to Brainmoto Levels (1-8)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '⚠️ Each level can only be assigned to one grade',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.orange),
                              ),
                              if (_actualGrades != null)
                                Text(
                                  'Grades currently in use: ${_actualGrades!.length}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Grade List
                      Expanded(
                        child: _localMapping.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _localMapping.length,
                                itemBuilder: (context, index) {
                                  final entry =
                                      _localMapping.entries.elementAt(index);
                                  final isUsedByStudents =
                                      _actualGrades?.contains(entry.key) ??
                                          false;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isUsedByStudents
                                            ? const Color(0xFF4e3f8a)
                                            : Colors.grey,
                                        child: Text(
                                          '${entry.value}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              entry.key,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (isUsedByStudents)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'IN USE',
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
                                          'Brainmoto Level ${entry.value}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          DropdownButton<int>(
                                            value: entry.value,
                                            underline: const SizedBox(),
                                            items:
                                                List.generate(8, (i) => i + 1)
                                                    .map((level) {
                                              final isLevelUsed = _isLevelUsed(
                                                  level, entry.key);
                                              return DropdownMenuItem(
                                                value: level,
                                                enabled: !isLevelUsed,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Level $level',
                                                      style: TextStyle(
                                                        color: isLevelUsed
                                                            ? Colors.grey
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                    if (isLevelUsed)
                                                      const SizedBox(width: 8),
                                                    if (isLevelUsed)
                                                      const Icon(Icons.block,
                                                          size: 14,
                                                          color: Colors.red),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              if (value != null &&
                                                  !_isLevelUsed(
                                                      value, entry.key)) {
                                                _updateMapping(
                                                    entry.key, value);
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _removeGrade(entry.key),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Action Buttons
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _addCustomGrade,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Custom Grade'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _hasChanges ? _saveMapping : null,
                              icon: provider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(provider.isLoading
                                  ? 'Saving...'
                                  : 'Save Mapping & Update Students'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor:
                                    _hasChanges ? Colors.green : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.link_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No grade mappings added yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addCustomGrade,
            icon: const Icon(Icons.add),
            label: const Text('Add First Grade'),
          ),
        ],
      ),
    );
  }
}

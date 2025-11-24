// lib/screens/coordinator/grade_level_mapping_screen.dart
import 'package:brainmoto_app/service/firebase_service.dart';
import 'package:flutter/material.dart';
import '../../models/school_model.dart';

class GradeLevelMappingScreen extends StatefulWidget {
  final SchoolModel school;

  const GradeLevelMappingScreen({super.key, required this.school});

  @override
  State<GradeLevelMappingScreen> createState() =>
      _GradeLevelMappingScreenState();
}

class _GradeLevelMappingScreenState extends State<GradeLevelMappingScreen> {
  late Map<String, int> _mapping;
  final _gradeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mapping = Map.from(widget.school.gradeToLevelMap);
  }

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  void _addGrade() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedLevel = 1;
        return AlertDialog(
          title: const Text('Add Grade Mapping'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _gradeController,
                decoration: const InputDecoration(
                  labelText: 'Grade Name',
                  hintText: 'e.g., Nursery, UKG, etc.',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Brainmoto Level',
                ),
                items: List.generate(8, (index) => index + 1)
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text('Level $level'),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedLevel = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_gradeController.text.isNotEmpty) {
                  setState(() {
                    _mapping[_gradeController.text.trim()] = selectedLevel;
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
  }

  Future<void> _saveMapping() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseService.updateSchool(
        widget.school.id,
        {'gradeToLevelMap': _mapping},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grade mapping saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mapping: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade-Level Mapping'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Map school-specific grade names to Brainmoto Levels (1-8)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Example: "Nursery" → Level 1, "UKG Rigel" → Level 2'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _mapping.isEmpty
                ? const Center(
                    child: Text('No grade mappings added yet'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _mapping.length,
                    itemBuilder: (context, index) {
                      final entry = _mapping.entries.elementAt(index);
                      return Card(
                        child: ListTile(
                          title: Text(entry.key),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text('Level ${entry.value}'),
                                backgroundColor: const Color(0xFF4e3f8a),
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _mapping.remove(entry.key);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: _addGrade,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Grade Mapping'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveMapping,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Mapping'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

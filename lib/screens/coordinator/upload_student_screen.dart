// lib/screens/coordinator/upload_students_refactored.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import '../../providers/coordinator_provider.dart';
import '../../models/student_model.dart';

class UploadStudentsScreenRefactored extends StatefulWidget {
  const UploadStudentsScreenRefactored({super.key});

  @override
  State<UploadStudentsScreenRefactored> createState() =>
      _UploadStudentsScreenRefactoredState();
}

class _UploadStudentsScreenRefactoredState
    extends State<UploadStudentsScreenRefactored> {
  List<StudentModel>? _parsedStudents;
  List<String>? _uniqueGrades;
  Map<String, int>? _gradeLevelMapping;
  int _currentStep = 0;
  String? _errorMessage;

  Future<void> _pickFile(BuildContext context) async {
    setState(() => _errorMessage = null);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: kIsWeb,
        withReadStream: false,
      );

      if (result == null) return;

      String csvString;

      if (kIsWeb) {
        if (result.files.first.bytes != null) {
          csvString = utf8.decode(result.files.first.bytes!);
        } else {
          setState(() => _errorMessage = 'Could not read file on web');
          return;
        }
      } else {
        if (result.files.first.path != null) {
          final file = File(result.files.first.path!);
          csvString = await file.readAsString();
        } else {
          setState(() => _errorMessage = 'Could not read file on mobile');
          return;
        }
      }

      final csvData = const CsvToListConverter().convert(csvString);
      _parseCSV(csvData, context);
    } catch (e) {
      setState(() => _errorMessage = 'Error reading file: $e');
    }
  }

  void _parseCSV(List<List<dynamic>> csvData, BuildContext context) {
    if (csvData.isEmpty) {
      setState(() => _errorMessage = 'CSV file is empty');
      return;
    }

    final headers =
        csvData[0].map((e) => e.toString().trim().toLowerCase()).toList();

    final nameIndex = headers.indexOf('name');
    final uidIndex = headers.indexOf('uid');
    final gradeIndex = headers.indexOf('grade');
    final divisionIndex = headers.indexOf('division');

    if (nameIndex == -1 ||
        uidIndex == -1 ||
        gradeIndex == -1 ||
        divisionIndex == -1) {
      setState(() {
        _errorMessage = 'Missing required columns: Name, UID, Grade, Division';
      });
      return;
    }

    final provider = Provider.of<CoordinatorProvider>(context, listen: false);
    final school = provider.selectedSchool!;

    final students = <StudentModel>[];
    final grades = <String>{};

    for (int i = 1; i < csvData.length; i++) {
      final row = csvData[i];

      if (row.length <= nameIndex ||
          row.length <= uidIndex ||
          row.length <= gradeIndex ||
          row.length <= divisionIndex) {
        continue;
      }

      final name = row[nameIndex].toString().trim();
      final uid = row[uidIndex].toString().trim();
      final grade = row[gradeIndex].toString().trim();
      final division = row[divisionIndex].toString().trim();

      if (name.isEmpty || uid.isEmpty || grade.isEmpty) continue;

      grades.add(grade);

      final student = StudentModel(
        id: '',
        uid: uid,
        name: name,
        schoolId: school.id,
        grade: grade,
        division: division,
        level: 1, // Will be updated after mapping
        createdAt: DateTime.now(),
      );

      students.add(student);
    }

    setState(() {
      _parsedStudents = students;
      _uniqueGrades = grades.toList()..sort();
      _currentStep = 1;

      // Initialize mapping
      _gradeLevelMapping = {};
      for (var grade in _uniqueGrades!) {
        _gradeLevelMapping![grade] = school.gradeToLevelMap[grade] ?? 1;
      }
    });
  }

  void _updateGradeMapping(String grade, int level) {
    setState(() => _gradeLevelMapping![grade] = level);
  }

  void _applyMappingToStudents() {
    if (_parsedStudents == null || _gradeLevelMapping == null) return;

    final provider = Provider.of<CoordinatorProvider>(context, listen: false);
    final school = provider.selectedSchool!;

    setState(() {
      _parsedStudents = _parsedStudents!.map((student) {
        final level = _gradeLevelMapping![student.grade] ?? 1;
        return StudentModel(
          id: student.id,
          uid: student.uid,
          name: student.name,
          schoolId: school.id,
          grade: student.grade,
          division: student.division,
          level: level,
          createdAt: student.createdAt,
        );
      }).toList();

      _currentStep = 2;
    });
  }

  Future<void> _uploadStudents(BuildContext context) async {
    if (_parsedStudents == null || _parsedStudents!.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Upload'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload ${_parsedStudents!.length} students?'),
            const SizedBox(height: 16),
            const Text('This will also update the grade-level mapping.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final provider = Provider.of<CoordinatorProvider>(context, listen: false);

    try {
      await provider.uploadStudentsBatch(_parsedStudents!, _gradeLevelMapping!);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Upload Successful!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${_parsedStudents!.length} students uploaded successfully.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Grade-Level Mapping Saved:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._gradeLevelMapping!.entries.map((entry) =>
                          Text('${entry.key} → Level ${entry.value}')),
                    ],
                  ),
                ),
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
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
            appBar: AppBar(title: const Text('Upload Students')),
            body: const Center(child: Text('No school selected')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Upload Students')),
          body: Stepper(
            currentStep: _currentStep,
            onStepTapped: (step) {
              if (step < _currentStep) {
                setState(() => _currentStep = step);
              }
            },
            onStepContinue: () {
              if (_currentStep == 0 && _parsedStudents != null) {
                setState(() => _currentStep = 1);
              } else if (_currentStep == 1 && _gradeLevelMapping != null) {
                _applyMappingToStudents();
              } else if (_currentStep == 2) {
                _uploadStudents(context);
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            steps: [
              Step(
                title: const Text('Upload CSV'),
                isActive: _currentStep >= 0,
                state:
                    _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: _buildStep1UploadCSV(context, school),
              ),
              Step(
                title: const Text('Map Grades to Levels'),
                isActive: _currentStep >= 1,
                state:
                    _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: _buildStep2MapGrades(),
              ),
              Step(
                title: const Text('Confirm & Upload'),
                isActive: _currentStep >= 2,
                content: _buildStep3Confirm(provider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep1UploadCSV(BuildContext context, school) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload to: ${school.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Required CSV columns:'),
                const Text('• Name'),
                const Text('• UID'),
                const Text('• Grade'),
                const Text('• Division'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _pickFile(context),
          icon: const Icon(Icons.upload_file),
          label: const Text('Select CSV File'),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ),
          ),
        ],
        if (_parsedStudents != null) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '✓ ${_parsedStudents!.length} students parsed\n✓ ${_uniqueGrades!.length} unique grades found',
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep2MapGrades() {
    if (_uniqueGrades == null || _gradeLevelMapping == null) {
      return const Text('Please upload CSV first');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Colors.amber[50],
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Map Each Grade to Brainmoto Level (1-8)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('These grades were found in your CSV:'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._uniqueGrades!.map((grade) => Card(
              child: ListTile(
                title: Text(grade,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: DropdownButton<int>(
                  value: _gradeLevelMapping![grade],
                  items: List.generate(8, (i) => i + 1).map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text('Level $level'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _updateGradeMapping(grade, value);
                    }
                  },
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildStep3Confirm(CoordinatorProvider provider) {
    if (_parsedStudents == null) {
      return const Text('Please complete previous steps');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready to Upload',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text('Students: ${_parsedStudents!.length}'),
                Text('Grades: ${_uniqueGrades!.length}'),
                const SizedBox(height: 16),
                const Text(
                  'Grade-Level Mapping:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ..._gradeLevelMapping!.entries
                    .map((e) => Text('${e.key} → Level ${e.value}')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Preview (first 5 students):'),
        const SizedBox(height: 8),
        ...List.generate(
          _parsedStudents!.length > 5 ? 5 : _parsedStudents!.length,
          (i) {
            final student = _parsedStudents![i];
            return Card(
              child: ListTile(
                title: Text(student.name),
                subtitle: Text(
                    'UID: ${student.uid}\n${student.grade} - ${student.division} | Level ${student.level}'),
                isThreeLine: true,
              ),
            );
          },
        ),
      ],
    );
  }
}

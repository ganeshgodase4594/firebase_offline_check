// lib/screens/coordinator/export_data_screen_refactored.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import '../../providers/coordinator_provider.dart';
import '../../models/assessment_model.dart';
import '../../models/student_model.dart';
import '../../service/firebase_service.dart';

class ExportDataScreenRefactored extends StatefulWidget {
  const ExportDataScreenRefactored({Key? key}) : super(key: key);

  @override
  State<ExportDataScreenRefactored> createState() =>
      _ExportDataScreenRefactoredState();
}

class _ExportDataScreenRefactoredState
    extends State<ExportDataScreenRefactored> {
  String _exportType = 'school';
  String? _selectedGrade;
  bool _isLoading = false;

  Future<void> _exportData(BuildContext context) async {
    final provider = Provider.of<CoordinatorProvider>(context, listen: false);
    final school = provider.selectedSchool!;

    if (_exportType == 'grade' && _selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a grade'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<AssessmentModel> assessments;

      if (_exportType == 'school') {
        assessments = await FirebaseService.getAssessmentsBySchool(school.id);
      } else {
        assessments = await FirebaseService.getAssessmentsBySchoolAndGrade(
          school.id,
          _selectedGrade!,
        );
      }

      // Get all students
      final studentsMap = <String, StudentModel>{};
      for (var assessment in assessments) {
        if (!studentsMap.containsKey(assessment.studentId)) {
          final student =
              await FirebaseService.getStudent(assessment.studentId);
          if (student != null) {
            studentsMap[assessment.studentId] = student;
          }
        }
      }

      // Generate CSV
      final csvData = _generateCSV(assessments, studentsMap);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Ready'),
            content: Text('${assessments.length} assessments ready to export'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generateCSV(
      List<AssessmentModel> assessments, Map<String, StudentModel> students) {
    final List<List<dynamic>> rows = [];

    // Headers
    rows.add([
      'Name',
      'UID',
      'Grade',
      'Division',
      'response0',
      'response1',
      'response2',
      'response3',
      'response4',
      'response5',
      'Level',
    ]);

    // Data rows
    for (var assessment in assessments) {
      final student = students[assessment.studentId];
      if (student != null) {
        rows.add([
          student.name,
          student.uid,
          student.grade,
          student.division,
          assessment.responses['response0'] ?? '',
          assessment.responses['response1'] ?? '',
          assessment.responses['response2'] ?? '',
          assessment.responses['response3'] ?? '',
          assessment.responses['response4'] ?? '',
          assessment.responses['response5'] ?? '',
          assessment.level,
        ]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        final school = provider.selectedSchool;

        if (school == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Export Assessment Data')),
            body: const Center(child: Text('No school selected')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Export Assessment Data')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Export Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('Entire School'),
                  value: 'school',
                  groupValue: _exportType,
                  onChanged: (value) {
                    setState(() {
                      _exportType = value!;
                      _selectedGrade = null;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Specific Grade'),
                  value: 'grade',
                  groupValue: _exportType,
                  onChanged: (value) {
                    setState(() => _exportType = value!);
                  },
                ),
                if (_exportType == 'grade') ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGrade,
                    decoration:
                        const InputDecoration(labelText: 'Select Grade'),
                    items: provider.availableGrades
                        .map((grade) => DropdownMenuItem(
                              value: grade,
                              child: Text(grade),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedGrade = value);
                    },
                  ),
                ],
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _exportData(context),
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: const Text('Generate & Download CSV'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// lib/screens/coordinator/upload_students_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import '../../models/school_model.dart';
import '../../models/student_model.dart';
import '../../service/firebase_service.dart';

class UploadStudentsScreen extends StatefulWidget {
  final SchoolModel school;

  const UploadStudentsScreen({Key? key, required this.school})
      : super(key: key);

  @override
  State<UploadStudentsScreen> createState() => _UploadStudentsScreenState();
}

class _UploadStudentsScreenState extends State<UploadStudentsScreen> {
  List<List<dynamic>>? _csvData;
  List<StudentModel>? _parsedStudents;
  bool _isLoading = false;
  String? _errorMessage;
  String? _debugMessage;

  Future<void> _pickFile() async {
    setState(() {
      _debugMessage = 'Opening file picker...';
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: kIsWeb, // Only read bytes on web
        withReadStream: false,
      );

      if (result == null) {
        setState(() {
          _debugMessage = 'No file selected';
        });
        return;
      }

      setState(() {
        _debugMessage = 'File selected: ${result.files.first.name}';
      });

      String csvString;

      // Different handling for Web vs Mobile
      if (kIsWeb) {
        // Web platform - use bytes
        if (result.files.first.bytes != null) {
          final bytes = result.files.first.bytes!;
          setState(() {
            _debugMessage = 'Reading file (Web)... Size: ${bytes.length} bytes';
          });
          csvString = utf8.decode(bytes);
        } else {
          setState(() {
            _errorMessage = 'Could not read file bytes on web';
            _debugMessage = 'Error: File bytes are null (Web)';
          });
          return;
        }
      } else {
        // Mobile platform (Android/iOS) - use path
        if (result.files.first.path != null) {
          setState(() {
            _debugMessage =
                'Reading file (Mobile)... Path: ${result.files.first.path}';
          });
          final file = File(result.files.first.path!);
          csvString = await file.readAsString();
        } else {
          setState(() {
            _errorMessage = 'Could not read file path on mobile';
            _debugMessage = 'Error: File path is null (Mobile)';
          });
          return;
        }
      }

      setState(() {
        _debugMessage = 'Decoding CSV...';
      });

      final List<List<dynamic>> csvData =
          const CsvToListConverter().convert(csvString);

      setState(() {
        _csvData = csvData;
        _errorMessage = null;
        _debugMessage = 'CSV loaded: ${csvData.length} rows found';
      });

      _parseCSV(csvData);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading file: $e';
        _debugMessage = 'Exception: $e\nPlatform: ${kIsWeb ? "Web" : "Mobile"}';
      });
      print('File picker error: $e');
    }
  }

  void _parseCSV(List<List<dynamic>> csvData) {
    setState(() {
      _debugMessage = 'Parsing CSV data...';
    });

    if (csvData.isEmpty) {
      setState(() {
        _errorMessage = 'CSV file is empty';
        _debugMessage = 'Error: No rows in CSV';
      });
      return;
    }

    print('CSV Headers: ${csvData[0]}');

    final headers =
        csvData[0].map((e) => e.toString().trim().toLowerCase()).toList();

    setState(() {
      _debugMessage = 'Headers found: ${headers.join(", ")}';
    });

    final nameIndex = headers.indexOf('name');
    final uidIndex = headers.indexOf('uid');
    final gradeIndex = headers.indexOf('grade');
    final divisionIndex = headers.indexOf('division');

    print(
        'Column indices - Name: $nameIndex, UID: $uidIndex, Grade: $gradeIndex, Division: $divisionIndex');

    if (nameIndex == -1 ||
        uidIndex == -1 ||
        gradeIndex == -1 ||
        divisionIndex == -1) {
      setState(() {
        _errorMessage = 'Missing required columns: Name, UID, Grade, Division';
        _debugMessage = 'Available headers: ${headers.join(", ")}';
      });
      return;
    }

    final students = <StudentModel>[];
    int skippedRows = 0;

    for (int i = 1; i < csvData.length; i++) {
      final row = csvData[i];

      if (row.length <= nameIndex ||
          row.length <= uidIndex ||
          row.length <= gradeIndex ||
          row.length <= divisionIndex) {
        skippedRows++;
        print('Skipped row $i: insufficient columns');
        continue;
      }

      final name = row[nameIndex].toString().trim();
      final uid = row[uidIndex].toString().trim();
      final grade = row[gradeIndex].toString().trim();
      final division = row[divisionIndex].toString().trim();

      if (name.isEmpty || uid.isEmpty || grade.isEmpty) {
        skippedRows++;
        print('Skipped row $i: empty required fields');
        continue;
      }

      // Get level from grade mapping
      final level = widget.school.gradeToLevelMap[grade] ?? 1;

      print('Row $i: $name, $uid, $grade, $division, Level: $level');

      final student = StudentModel(
        id: '',
        uid: uid,
        name: name,
        schoolId: widget.school.id,
        grade: grade,
        division: division,
        level: level,
        createdAt: DateTime.now(),
      );

      students.add(student);
    }

    setState(() {
      _parsedStudents = students;
      _debugMessage =
          'Parsed ${students.length} students. Skipped $skippedRows rows.';
    });

    print('Total students parsed: ${students.length}');
  }

  Future<void> _uploadStudents() async {
    if (_parsedStudents == null || _parsedStudents!.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Upload'),
        content: Text(
          'Are you sure you want to upload ${_parsedStudents!.length} students to ${widget.school.name}?',
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

    setState(() {
      _isLoading = true;
      _debugMessage = 'Starting upload...';
    });

    try {
      print('Creating batch of ${_parsedStudents!.length} students');

      final ids = await FirebaseService.createStudentsBatch(_parsedStudents!);

      print('Upload successful. Created ${ids.length} students');

      setState(() {
        _isLoading = false;
        _debugMessage = 'Upload completed successfully!';
      });

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
                  '${_parsedStudents!.length} students have been uploaded successfully to ${widget.school.name}.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Students are now available for assessment.',
                          style: TextStyle(color: Colors.green[900]),
                        ),
                      ),
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
      print('Upload error: $e');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Error uploading students: $e';
        _debugMessage = 'Upload failed with exception: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading students: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Students'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Upload to: ${widget.school.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Required CSV columns:'),
                    const Text('• Name (Student full name)'),
                    const Text('• UID (Unique ID: schoolCode + number)'),
                    const Text('• Grade (e.g., Nursery, UKG, etc.)'),
                    const Text('• Division (e.g., A, B, Rigel, etc.)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_debugMessage != null)
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.bug_report,
                          size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _debugMessage!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select CSV File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_parsedStudents != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '${_parsedStudents!.length} students ready to upload',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Preview (first 10 students):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    itemCount: _parsedStudents!.length > 10
                        ? 10
                        : _parsedStudents!.length,
                    itemBuilder: (context, index) {
                      final student = _parsedStudents![index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(student.name),
                        subtitle: Text(
                          'UID: ${student.uid}\n${student.grade} - ${student.division} | Level ${student.level}',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
              ),
              if (_parsedStudents!.length > 10)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '... and ${_parsedStudents!.length - 10} more students',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _uploadStudents,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_isLoading ? 'Uploading...' : 'Upload Students'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

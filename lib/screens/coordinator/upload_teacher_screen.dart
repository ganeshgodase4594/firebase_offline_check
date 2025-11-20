// lib/screens/coordinator/upload_teachers_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import '../../models/school_model.dart';
import '../../models/user_model.dart';
import '../../service/firebase_service.dart';

class UploadTeachersScreen extends StatefulWidget {
  final SchoolModel school;

  const UploadTeachersScreen({Key? key, required this.school})
      : super(key: key);

  @override
  State<UploadTeachersScreen> createState() => _UploadTeachersScreenState();
}

class _UploadTeachersScreenState extends State<UploadTeachersScreen> {
  List<List<dynamic>>? _csvData;
  List<TeacherData>? _parsedTeachers;
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
        withData: kIsWeb,
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

      if (kIsWeb) {
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
    final emailIndex = headers.indexOf('email');
    final phoneIndex = headers.indexOf('phone');
    final gradesIndex = headers.indexOf('assignedgrades');

    print(
        'Column indices - Name: $nameIndex, Email: $emailIndex, Phone: $phoneIndex, Grades: $gradesIndex');

    if (nameIndex == -1 || emailIndex == -1 || gradesIndex == -1) {
      setState(() {
        _errorMessage = 'Missing required columns: Name, Email, AssignedGrades';
        _debugMessage = 'Available headers: ${headers.join(", ")}';
      });
      return;
    }

    final teachers = <TeacherData>[];
    int skippedRows = 0;

    for (int i = 1; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.length <= nameIndex ||
          row.length <= emailIndex ||
          row.length <= gradesIndex) {
        skippedRows++;
        print('Skipped row $i: insufficient columns');
        continue;
      }

      final name = row[nameIndex].toString().trim();
      final email = row[emailIndex].toString().trim();
      final phone = phoneIndex != -1 && row.length > phoneIndex
          ? row[phoneIndex].toString().trim()
          : null;
      final gradesStr = row[gradesIndex].toString().trim();

      if (name.isEmpty || email.isEmpty || gradesStr.isEmpty) {
        skippedRows++;
        print('Skipped row $i: empty required fields');
        continue;
      }

      final grades = gradesStr
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toList();

      final tempPassword = _generatePassword(name);

      print(
          'Row $i: $name, $email, Grades: ${grades.join(", ")}, Password: $tempPassword');

      teachers.add(TeacherData(
        name: name,
        email: email,
        phone: phone,
        assignedGrades: grades,
        tempPassword: tempPassword,
      ));
    }

    setState(() {
      _parsedTeachers = teachers;
      _debugMessage =
          'Parsed ${teachers.length} teachers. Skipped $skippedRows rows.';
    });

    print('Total teachers parsed: ${teachers.length}');
  }

  String _generatePassword(String name) {
    final firstName = name.split(' ').first;
    return '${firstName}@123';
  }

  Future<void> _uploadTeachers() async {
    if (_parsedTeachers == null || _parsedTeachers!.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Upload'),
        content: Text(
          'Are you sure you want to create ${_parsedTeachers!.length} teacher accounts for ${widget.school.name}?\n\nTemporary passwords will be generated.',
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

    int successCount = 0;
    int errorCount = 0;
    List<String> errors = [];
    List<String> successEmails = [];

    for (var teacherData in _parsedTeachers!) {
      try {
        print('Creating account for: ${teacherData.email}');

        setState(() {
          _debugMessage = 'Creating account for ${teacherData.name}...';
        });

        final userCredential =
            await FirebaseService.createUserWithEmailPassword(
          teacherData.email,
          teacherData.tempPassword,
        );

        print(
            'Firebase Auth created for: ${teacherData.email}, UID: ${userCredential.user!.uid}');

        final user = UserModel(
          uid: userCredential.user!.uid,
          email: teacherData.email,
          name: teacherData.name,
          role: UserRole.teacher,
          schoolId: widget.school.id,
          assignedGrades: teacherData.assignedGrades,
          phoneNumber: teacherData.phone,
          createdAt: DateTime.now(),
          isActive: true,
        );

        await FirebaseService.createUser(user);
        print('Firestore document created for: ${teacherData.email}');

        successCount++;
        successEmails.add('${teacherData.email} : ${teacherData.tempPassword}');
      } on FirebaseAuthException catch (e) {
        print(
            'Firebase Auth error for ${teacherData.email}: ${e.code} - ${e.message}');
        errorCount++;
        if (e.code == 'email-already-in-use') {
          errors.add('${teacherData.email}: Email already exists');
        } else {
          errors.add('${teacherData.email}: ${e.message}');
        }
      } catch (e) {
        print('General error for ${teacherData.email}: $e');
        errorCount++;
        errors.add('${teacherData.email}: $e');
      }
    }

    setState(() {
      _isLoading = false;
      _debugMessage =
          'Upload completed. Success: $successCount, Failed: $errorCount';
    });

    if (mounted) {
      if (errorCount == 0) {
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
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Successfully created $successCount teacher accounts for ${widget.school.name}.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.vpn_key, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Login Credentials',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Share these credentials with teachers:',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        ...successEmails.map((cred) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                cred,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.done),
                label: const Text('Done'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text('Upload Complete with Errors'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✓ Success: $successCount',
                      style: const TextStyle(color: Colors.green)),
                  Text('✗ Failed: $errorCount',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  if (successCount > 0) ...[
                    const Text(
                      'Successful Accounts:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ...successEmails.map((cred) => Text(
                          '✓ $cred',
                          style: const TextStyle(fontSize: 11),
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (errors.isNotEmpty) ...[
                    const Text(
                      'Errors:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...errors.map((e) => Text(
                          '✗ $e',
                          style: const TextStyle(fontSize: 11),
                        )),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Teachers'),
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
                    const Text('• Name (Teacher full name)'),
                    const Text('• Email (Unique email address)'),
                    const Text('• Phone (Contact number, optional)'),
                    const Text(
                        '• AssignedGrades (Comma-separated, e.g., "Nursery,UKG")'),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: Password format will be "FirstName@123"',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue,
                      ),
                    ),
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
            if (_parsedTeachers != null) ...[
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
                        '${_parsedTeachers!.length} teachers ready to upload',
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
                'Preview (first 10 teachers):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    itemCount: _parsedTeachers!.length > 10
                        ? 10
                        : _parsedTeachers!.length,
                    itemBuilder: (context, index) {
                      final teacher = _parsedTeachers![index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(teacher.name),
                        subtitle: Text(
                          'Email: ${teacher.email}\nGrades: ${teacher.assignedGrades.join(", ")}\nPassword: ${teacher.tempPassword}',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
              ),
              if (_parsedTeachers!.length > 10)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '... and ${_parsedTeachers!.length - 10} more teachers',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _uploadTeachers,
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
                label: Text(_isLoading ? 'Uploading...' : 'Upload Teachers'),
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

class TeacherData {
  final String name;
  final String email;
  final String? phone;
  final List<String> assignedGrades;
  final String tempPassword;

  TeacherData({
    required this.name,
    required this.email,
    this.phone,
    required this.assignedGrades,
    required this.tempPassword,
  });
}

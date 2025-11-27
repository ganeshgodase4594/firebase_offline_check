// /*
// with old csv
// */

// // lib/screens/coordinator/upload_teachers_refactored.dart
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:csv/csv.dart';
// import 'dart:convert';
// import 'dart:io';
// import '../../providers/coordinator_provider.dart';

// class UploadTeachersScreenRefactored extends StatefulWidget {
//   const UploadTeachersScreenRefactored({super.key});

//   @override
//   State<UploadTeachersScreenRefactored> createState() =>
//       _UploadTeachersScreenRefactoredState();
// }

// class _UploadTeachersScreenRefactoredState
//     extends State<UploadTeachersScreenRefactored> {
//   List<Map<String, dynamic>>? _parsedTeachers;
//   String? _errorMessage;

//   Future<void> _pickFile(BuildContext context) async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['csv'],
//         withData: kIsWeb,
//       );

//       if (result == null) return;

//       String csvString;
//       if (kIsWeb) {
//         csvString = utf8.decode(result.files.first.bytes!);
//       } else {
//         final file = File(result.files.first.path!);
//         csvString = await file.readAsString();
//       }

//       final csvData = const CsvToListConverter().convert(csvString);
//       _parseCSV(csvData);
//     } catch (e) {
//       setState(() => _errorMessage = 'Error reading file: $e');
//     }
//   }

//   void _parseCSV(List<List<dynamic>> csvData) {
//     if (csvData.isEmpty) {
//       setState(() => _errorMessage = 'CSV file is empty');
//       return;
//     }

//     final headers =
//         csvData[0].map((e) => e.toString().trim().toLowerCase()).toList();

//     final nameIndex = headers.indexOf('name');
//     final emailIndex = headers.indexOf('email');
//     final phoneIndex = headers.indexOf('phone');
//     final gradesIndex = headers.indexOf('assignedgradesdivisions');

//     if (nameIndex == -1 || emailIndex == -1 || gradesIndex == -1) {
//       setState(() {
//         _errorMessage =
//             'Missing required columns: Name, Email, AssignedGradesDivisions';
//       });
//       return;
//     }

//     final teachers = <Map<String, dynamic>>[];

//     for (int i = 1; i < csvData.length; i++) {
//       final row = csvData[i];
//       if (row.length <= nameIndex ||
//           row.length <= emailIndex ||
//           row.length <= gradesIndex) {
//         continue;
//       }

//       final name = row[nameIndex].toString().trim();
//       final email = row[emailIndex].toString().trim();
//       final phone = phoneIndex != -1 && row.length > phoneIndex
//           ? row[phoneIndex].toString().trim()
//           : null;
//       final gradesStr = row[gradesIndex].toString().trim();

//       if (name.isEmpty || email.isEmpty || gradesStr.isEmpty) continue;

//       // Parse grade-division assignments
//       final gradeAssignments = <String, List<String>>{};

//       final assignments =
//           gradesStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);

//       for (var assignment in assignments) {
//         if (assignment.contains('-')) {
//           final parts = assignment.split('-');
//           final grade = parts[0].trim();
//           final division = parts[1].trim();

//           if (!gradeAssignments.containsKey(grade)) {
//             gradeAssignments[grade] = [];
//           }
//           gradeAssignments[grade]!.add(division);
//         } else {
//           if (!gradeAssignments.containsKey(assignment)) {
//             gradeAssignments[assignment] = [];
//           }
//         }
//       }

//       final tempPassword = _generatePassword(name);

//       teachers.add({
//         'name': name,
//         'email': email,
//         'phone': phone,
//         'gradeAssignments': gradeAssignments,
//         'password': tempPassword,
//       });
//     }

//     setState(() {
//       _parsedTeachers = teachers;
//       _errorMessage = null;
//     });
//   }

//   String _generatePassword(String name) {
//     final firstName = name.split(' ').first;
//     return '${firstName}@123';
//   }

//   Future<void> _uploadTeachers(BuildContext context) async {
//     if (_parsedTeachers == null || _parsedTeachers!.isEmpty) return;

//     final provider = Provider.of<CoordinatorProvider>(context, listen: false);

//     try {
//       final result = await provider.uploadTeachersBatch(_parsedTeachers!);

//       if (mounted) {
//         _showUploadResult(
//           context,
//           result['success'] as int,
//           result['errors'] as int,
//           result['credentials'] as List<String>,
//           result['errorMessages'] as List<String>,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   void _showUploadResult(
//     BuildContext context,
//     int successCount,
//     int errorCount,
//     List<String> credentials,
//     List<String> errors,
//   ) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(
//               errorCount == 0 ? Icons.check_circle : Icons.warning,
//               color: errorCount == 0 ? Colors.green : Colors.orange,
//               size: 32,
//             ),
//             const SizedBox(width: 12),
//             Text(errorCount == 0
//                 ? 'Upload Successful!'
//                 : 'Upload Complete with Errors'),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('✓ Success: $successCount',
//                   style: const TextStyle(color: Colors.green)),
//               if (errorCount > 0)
//                 Text('✗ Failed: $errorCount',
//                     style: const TextStyle(color: Colors.red)),
//               const SizedBox(height: 16),
//               if (successCount > 0) ...[
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.amber[50],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.amber),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.vpn_key, color: Colors.orange),
//                           SizedBox(width: 8),
//                           Text('Login Credentials',
//                               style: TextStyle(fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       ...credentials.map((cred) => Padding(
//                             padding: const EdgeInsets.only(bottom: 4),
//                             child: Text(cred,
//                                 style: const TextStyle(
//                                     fontSize: 11, fontFamily: 'monospace')),
//                           )),
//                     ],
//                   ),
//                 ),
//               ],
//               if (errors.isNotEmpty) ...[
//                 const SizedBox(height: 16),
//                 const Text('Errors:',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold, color: Colors.red)),
//                 ...errors.map(
//                     (e) => Text('✗ $e', style: const TextStyle(fontSize: 11))),
//               ],
//             ],
//           ),
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               if (errorCount == 0) Navigator.pop(context);
//             },
//             child: const Text('Done'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CoordinatorProvider>(
//       builder: (context, provider, child) {
//         final school = provider.selectedSchool;

//         if (school == null) {
//           return Scaffold(
//             appBar: AppBar(title: const Text('Upload Teachers')),
//             body: const Center(child: Text('No school selected')),
//           );
//         }

//         return Scaffold(
//           appBar: AppBar(title: const Text('Upload Teachers')),
//           body: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Card(
//                   color: Colors.blue[50],
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Upload to: ${school.name}',
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16),
//                         ),
//                         const SizedBox(height: 12),
//                         const Text('Required CSV columns:'),
//                         const Text('• Name'),
//                         const Text('• Email'),
//                         const Text('• Phone (optional)'),
//                         const Text('• AssignedGradesDivisions'),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'Format: "Nursery-A,UKG-Rigel,LKG"',
//                           style: TextStyle(
//                               fontSize: 12, fontStyle: FontStyle.italic),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton.icon(
//                   onPressed: provider.isUploadingData
//                       ? null
//                       : () => _pickFile(context),
//                   icon: const Icon(Icons.upload_file),
//                   label: const Text('Select CSV File'),
//                 ),
//                 if (_errorMessage != null) ...[
//                   const SizedBox(height: 16),
//                   Card(
//                     color: Colors.red[50],
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Text(_errorMessage!,
//                           style: const TextStyle(color: Colors.red)),
//                     ),
//                   ),
//                 ],
//                 if (_parsedTeachers != null) ...[
//                   const SizedBox(height: 16),
//                   Card(
//                     color: Colors.green[50],
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Text(
//                         '${_parsedTeachers!.length} teachers ready to upload',
//                         style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: Card(
//                       child: ListView.builder(
//                         itemCount: _parsedTeachers!.length,
//                         itemBuilder: (context, index) {
//                           final teacher = _parsedTeachers![index];
//                           return ListTile(
//                             title: Text(teacher['name']),
//                             subtitle: Text(
//                               'Email: ${teacher['email']}\n'
//                               'Password: ${teacher['password']}',
//                             ),
//                             isThreeLine: true,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: provider.isUploadingData
//                         ? null
//                         : () => _uploadTeachers(context),
//                     icon: provider.isUploadingData
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                                 color: Colors.white, strokeWidth: 2),
//                           )
//                         : const Icon(Icons.cloud_upload),
//                     label: Text(provider.isUploadingData
//                         ? 'Uploading...'
//                         : 'Upload Teachers'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       backgroundColor: Colors.green,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

/*
with new csv
*/

// lib/screens/coordinator/upload_teachers_new_format.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import '../../providers/coordinator_provider.dart';

class UploadTeachersNewFormat extends StatefulWidget {
  const UploadTeachersNewFormat({super.key});

  @override
  State<UploadTeachersNewFormat> createState() =>
      _UploadTeachersNewFormatState();
}

class _UploadTeachersNewFormatState extends State<UploadTeachersNewFormat> {
  List<Map<String, dynamic>>? _parsedTeachers;
  String? _errorMessage;
  List<String> _validationWarnings = [];

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: kIsWeb,
      );

      if (result == null) return;

      String csvString;
      if (kIsWeb) {
        csvString = utf8.decode(result.files.first.bytes!);
      } else {
        final file = File(result.files.first.path!);
        csvString = await file.readAsString();
      }

      final csvData = const CsvToListConverter().convert(csvString);
      _parseCSV(csvData);
    } catch (e) {
      setState(() => _errorMessage = 'Error reading file: $e');
    }
  }

  void _parseCSV(List<List<dynamic>> csvData) {
    if (csvData.isEmpty) {
      setState(() => _errorMessage = 'CSV file is empty');
      return;
    }

    final headers =
        csvData[0].map((e) => e.toString().trim().toLowerCase()).toList();

    // Find column indices for NEW format
    final nameIndex = headers.indexOf('name');
    final emailIndex = headers.indexOf('email');
    final passwordIndex = headers.indexOf('password');
    final gradesIndex = headers.indexOf('grades');
    final divisionIndex = headers.indexOf('division');

    if (nameIndex == -1 || emailIndex == -1 || gradesIndex == -1) {
      setState(() {
        _errorMessage = 'Missing required columns: Name, Email, Grades';
      });
      return;
    }

    // Group rows by email (since same teacher appears multiple times)
    final Map<String, Map<String, dynamic>> teachersMap = {};
    final warnings = <String>[];

    for (int i = 1; i < csvData.length; i++) {
      final row = csvData[i];

      if (row.isEmpty || row.length <= gradesIndex) continue;

      final name = row[nameIndex].toString().trim();
      final email = row[emailIndex].toString().trim();
      final password = passwordIndex != -1 && row.length > passwordIndex
          ? row[passwordIndex].toString().trim()
          : '';
      final grade = row[gradesIndex].toString().trim();
      final division = divisionIndex != -1 && row.length > divisionIndex
          ? row[divisionIndex].toString().trim()
          : '';

      if (name.isEmpty || email.isEmpty || grade.isEmpty) continue;

      // Validate email format
      if (!_isValidEmail(email)) {
        warnings.add('Invalid email format: $email (Row ${i + 1})');
        continue;
      }

      // If teacher doesn't exist in map, create entry
      if (!teachersMap.containsKey(email)) {
        teachersMap[email] = {
          'name': name,
          'email': email,
          'password': password.isNotEmpty ? password : _generatePassword(name),
          'gradeAssignments': <String, List<String>>{},
        };
      }

      // Add grade-division assignment
      final gradeAssignments =
          teachersMap[email]!['gradeAssignments'] as Map<String, List<String>>;

      if (!gradeAssignments.containsKey(grade)) {
        gradeAssignments[grade] = [];
      }

      // Only add division if it's not empty and not already added
      if (division.isNotEmpty && !gradeAssignments[grade]!.contains(division)) {
        gradeAssignments[grade]!.add(division);
      } else if (division.isEmpty && gradeAssignments[grade]!.isEmpty) {
        // If no division specified and grade has no divisions yet, keep it empty
        // This means teacher is assigned to entire grade
      }
    }

    // Convert map to list
    final teachers = teachersMap.values.toList();

    if (teachers.isEmpty) {
      setState(() {
        _errorMessage = 'No valid teachers found in CSV';
        _validationWarnings = warnings;
      });
      return;
    }

    setState(() {
      _parsedTeachers = teachers;
      _errorMessage = null;
      _validationWarnings = warnings;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  String _generatePassword(String name) {
    final firstName = name.split(' ').first;
    return '${firstName}@123';
  }

  String _formatGradeAssignments(Map<String, List<String>> assignments) {
    final List<String> formatted = [];
    assignments.forEach((grade, divisions) {
      if (divisions.isEmpty) {
        formatted.add(grade);
      } else {
        for (var division in divisions) {
          formatted.add('$grade-$division');
        }
      }
    });
    return formatted.join(', ');
  }

  Future<void> _uploadTeachers(BuildContext context) async {
    if (_parsedTeachers == null || _parsedTeachers!.isEmpty) return;

    final provider = Provider.of<CoordinatorProvider>(context, listen: false);

    try {
      final result = await provider.uploadTeachersBatch(_parsedTeachers!);

      if (mounted) {
        _showUploadResult(
          context,
          result['success'] as int,
          result['errors'] as int,
          result['credentials'] as List<String>,
          result['errorMessages'] as List<String>,
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

  void _showUploadResult(
    BuildContext context,
    int successCount,
    int errorCount,
    List<String> credentials,
    List<String> errors,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              errorCount == 0 ? Icons.check_circle : Icons.warning,
              color: errorCount == 0 ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorCount == 0
                    ? 'Upload Successful!'
                    : 'Upload Complete with Errors',
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✓ Success: $successCount',
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
              if (errorCount > 0)
                Text('✗ Failed: $errorCount',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (successCount > 0) ...[
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
                          Icon(Icons.vpn_key, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text('Login Credentials',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...credentials.map((cred) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: SelectableText(
                              cred,
                              style: const TextStyle(
                                  fontSize: 12, fontFamily: 'monospace'),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Errors:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 4),
                ...errors.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text('✗ $e', style: const TextStyle(fontSize: 11)),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          if (errorCount > 0)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Review'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (errorCount == 0) Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        final school = provider.selectedSchool;

        if (school == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Upload Teachers')),
            body: const Center(
                child:
                    Text('No school selected', style: TextStyle(fontSize: 16))),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Upload Teachers'),
            elevation: 2,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.blue[50],
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.school,
                                color: Colors.blue, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Upload to: ${school.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        const Text('📋 Required CSV columns:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildRequirementRow('Name', true),
                        _buildRequirementRow('Email', true),
                        _buildRequirementRow('Password', false),
                        _buildRequirementRow('Grades', true),
                        _buildRequirementRow('Division', false),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💡 Format Example:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('Multiple rows per teacher:',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(
                                'Ajay, ajay@mail.com, Pass123, Sr. Kg, A\n'
                                'Ajay, ajay@mail.com, Pass123, Jr. Kg, B\n'
                                'Ajay, ajay@mail.com, Pass123, Grade 4, A',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: provider.isUploadingData
                      ? null
                      : () => _pickFile(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Select CSV File'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                if (_validationWarnings.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.orange[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Warnings',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._validationWarnings.map((w) => Text('⚠ $w',
                              style: const TextStyle(fontSize: 11))),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(_errorMessage!,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (_parsedTeachers != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.green[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_parsedTeachers!.length} teachers ready to upload',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[300]!)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.preview, size: 20),
                              SizedBox(width: 8),
                              Text('Preview',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _parsedTeachers!.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final teacher = _parsedTeachers![index];
                              final gradeAssignments =
                                  teacher['gradeAssignments']
                                      as Map<String, List<String>>;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    teacher['name'][0].toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(teacher['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('📧 ${teacher['email']}',
                                        style: const TextStyle(fontSize: 12)),
                                    Text('🔑 ${teacher['password']}',
                                        style: const TextStyle(fontSize: 12)),
                                    Text(
                                        '📚 ${_formatGradeAssignments(gradeAssignments)}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.blue)),
                                  ],
                                ),
                                isThreeLine: true,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: provider.isUploadingData
                        ? null
                        : () => _uploadTeachers(context),
                    icon: provider.isUploadingData
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(provider.isUploadingData
                        ? 'Uploading...'
                        : 'Upload ${_parsedTeachers!.length} Teachers'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementRow(String field, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            required ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: required ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            field,
            style: TextStyle(
              color: required ? Colors.black : Colors.grey[600],
            ),
          ),
          if (!required)
            Text(
              ' (optional)',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }
}

// lib/screens/coordinator/school_detail_screen_refactored.dart
import 'package:brainmoto_app/screens/coordinator/acadamic_year_managment.dart';
import 'package:brainmoto_app/screens/coordinator/add_teacher_screen.dart';
import 'package:brainmoto_app/screens/coordinator/export_data_screen.dart';
import 'package:brainmoto_app/screens/coordinator/grade_level_mapping_screen.dart';
import 'package:brainmoto_app/screens/coordinator/student_managment-screen.dart';
import 'package:brainmoto_app/screens/coordinator/teacher_managment_screen.dart';
import 'package:brainmoto_app/screens/coordinator/upload_student_screen.dart';
import 'package:brainmoto_app/screens/coordinator/upload_teacher_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coordinator_provider.dart';

class SchoolDetailScreenRefactored extends StatelessWidget {
  const SchoolDetailScreenRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        final school = provider.selectedSchool;

        if (school == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('School Details')),
            body: const Center(child: Text('No school selected')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(school.name),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // School Info Card
              _buildSchoolInfoCard(school),
              const SizedBox(height: 24),

              // Academic Year Section
              _buildSectionHeader('Academic Year'),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                'Academic Year & Terms',
                'Manage academic year, terms, and archive data',
                Icons.calendar_today,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AcademicYearManagementRefactored(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionHeader('Data Management'),
              const SizedBox(height: 12),

              _buildActionCard(
                context,
                'Grade-Level Mapping',
                'Map school grades to Brainmoto levels',
                Icons.link,
                Colors.purple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GradeRemappingScreenRefactored(),
                  ),
                ),
              ),

              _buildActionCard(
                context,
                'Manage Students',
                'View, add, edit, and manage students',
                Icons.people,
                Colors.green,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StudentManagementScreenRefactored(),
                  ),
                ),
              ),

              _buildActionCard(
                context,
                'Bulk Upload Students (CSV)',
                'Import multiple students via CSV file',
                Icons.upload_file,
                Colors.teal,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadStudentsScreenRefactored(),
                  ),
                ),
              ),

              _buildActionCard(
                context,
                'Manage Teachers',
                'View, edit assignments, and manage teachers',
                Icons.person,
                Colors.indigo,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeacherManagementScreenRefactored(),
                  ),
                ),
              ),

              _buildActionCard(
                context,
                'Add Individual Teacher',
                'Create a single teacher account',
                Icons.person_add,
                Colors.blue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTeacherScreenRefactored(),
                  ),
                ),
              ),

              _buildActionCard(
                context,
                'Bulk Upload Teachers (CSV)',
                'Import multiple teachers via CSV file',
                Icons.upload,
                Colors.cyan,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadTeachersNewFormat(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Reports Section
              _buildSectionHeader('Reports & Export'),
              const SizedBox(height: 12),

              _buildActionCard(
                context,
                'Export Assessment Data',
                'Download assessment results as CSV',
                Icons.download,
                Colors.orange,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExportDataScreenRefactored(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSchoolInfoCard(school) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school, color: Color(0xFF4e3f8a)),
                const SizedBox(width: 8),
                const Text(
                  'School Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Code', school.code),
            _buildInfoRow('City', school.city),
            _buildInfoRow('Area', school.area),
            _buildInfoRow('Address', school.address),
            _buildInfoRow('Principal', school.principalName),
            if (school.phoneNumber != null)
              _buildInfoRow('Phone', school.phoneNumber!),
            if (school.email != null) _buildInfoRow('Email', school.email!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4e3f8a),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

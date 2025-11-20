// lib/screens/coordinator/school_detail_screen.dart
import 'package:brainmoto_app/screens/coordinator/upload_student_screen.dart';
import 'package:brainmoto_app/screens/coordinator/upload_teacher_screen.dart';
import 'package:flutter/material.dart';
import '../../models/school_model.dart';
import 'export_data_screen.dart';
import 'grade_level_mapping_screen.dart';

class SchoolDetailScreen extends StatelessWidget {
  final SchoolModel school;

  const SchoolDetailScreen({Key? key, required this.school}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(school.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // School Info Card
          Card(
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
                  if (school.email != null)
                    _buildInfoRow('Email', school.email!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Management Options
          const Text(
            'Data Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4e3f8a),
            ),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context,
            'Upload Students',
            'Import student data via CSV',
            Icons.upload_file,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadStudentsScreen(school: school),
                ),
              );
            },
          ),

          _buildActionCard(
            context,
            'Upload Teachers',
            'Import teacher data via CSV',
            Icons.person_add,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadTeachersScreen(school: school),
                ),
              );
            },
          ),

          _buildActionCard(
            context,
            'Grade-Level Mapping',
            'Map school grades to Brainmoto levels',
            Icons.link,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GradeLevelMappingScreen(school: school),
                ),
              );
            },
          ),

          _buildActionCard(
            context,
            'Export Assessment Data',
            'Download or sync assessment results',
            Icons.download,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExportDataScreen(school: school),
                ),
              );
            },
          ),
        ],
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4e3f8a).withOpacity(0.1),
          child: Icon(icon, color: const Color(0xFF4e3f8a)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

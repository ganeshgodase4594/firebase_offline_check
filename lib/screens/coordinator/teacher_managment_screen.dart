// // lib/screens/coordinator/teacher_management_screen_refactored.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/coordinator_provider.dart';
// import '../../models/user_model.dart';

// class TeacherManagementScreenRefactored extends StatelessWidget {
//   const TeacherManagementScreenRefactored({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Teacher Management'),
//       ),
//       body: Column(
//         children: [
//           _buildSearchAndFilters(),
//           _buildStats(),
//           Expanded(child: _buildTeachersList()),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchAndFilters() {
//     return Consumer<CoordinatorProvider>(
//       builder: (context, provider, child) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.white,
//           child: Column(
//             children: [
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search by name or email',
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: provider.searchQuery.isNotEmpty
//                       ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () => provider.setSearchQuery(''),
//                         )
//                       : null,
//                 ),
//                 onChanged: (value) => provider.setSearchQuery(value),
//               ),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<String>(
//                 value: provider.selectedGrade,
//                 decoration: const InputDecoration(
//                   labelText: 'Filter by Grade',
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 ),
//                 items: [
//                   const DropdownMenuItem(
//                       value: null, child: Text('All Grades')),
//                   ...provider.availableGrades.map((grade) => DropdownMenuItem(
//                         value: grade,
//                         child: Text(grade),
//                       )),
//                 ],
//                 onChanged: (value) => provider.setGradeFilter(value),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStats() {
//     return Consumer<CoordinatorProvider>(
//       builder: (context, provider, child) {
//         final filtered = provider.filteredTeachers;
//         final total = provider.teachers;

//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           color: Colors.grey[100],
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Showing ${filtered.length} of ${total.length} teachers',
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//               if (provider.selectedGrade != null ||
//                   provider.searchQuery.isNotEmpty)
//                 TextButton.icon(
//                   onPressed: () => provider.clearFilters(),
//                   icon: const Icon(Icons.clear, size: 16),
//                   label: const Text('Clear Filters',
//                       style: TextStyle(fontSize: 12)),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTeachersList() {
//     return Consumer<CoordinatorProvider>(
//       builder: (context, provider, child) {
//         if (provider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final teachers = provider.filteredTeachers;

//         if (teachers.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'No teachers found',
//                   style: TextStyle(fontSize: 18, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: teachers.length,
//           itemBuilder: (context, index) {
//             final teacher = teachers[index];
//             return _buildTeacherCard(context, teacher, provider);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildTeacherCard(
//     BuildContext context,
//     UserModel teacher,
//     CoordinatorProvider provider,
//   ) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ExpansionTile(
//         leading: CircleAvatar(
//           backgroundColor:
//               teacher.isActive ? const Color(0xFF4e3f8a) : Colors.grey,
//           child: Text(
//             teacher.name.substring(0, 1).toUpperCase(),
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//         title: Row(
//           children: [
//             Expanded(child: Text(teacher.name)),
//             if (!teacher.isActive)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.grey,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: const Text(
//                   'INACTIVE',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(teacher.email),
//             if (teacher.phoneNumber != null)
//               Text('Phone: ${teacher.phoneNumber}'),
//           ],
//         ),
//         trailing: PopupMenuButton<String>(
//           onSelected: (value) =>
//               _handleTeacherAction(context, value, teacher, provider),
//           itemBuilder: (context) => [
//             const PopupMenuItem(
//               value: 'edit',
//               child: Row(
//                 children: [
//                   Icon(Icons.edit),
//                   SizedBox(width: 8),
//                   Text('Edit Assignments'),
//                 ],
//               ),
//             ),
//             if (teacher.isActive)
//               const PopupMenuItem(
//                 value: 'deactivate',
//                 child: Row(
//                   children: [
//                     Icon(Icons.block, color: Colors.red),
//                     SizedBox(width: 8),
//                     Text('Deactivate', style: TextStyle(color: Colors.red)),
//                   ],
//                 ),
//               )
//             else
//               const PopupMenuItem(
//                 value: 'reactivate',
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.green),
//                     SizedBox(width: 8),
//                     Text('Reactivate', style: TextStyle(color: Colors.green)),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//         children: [
//           _buildAssignmentsSection(teacher),
//         ],
//       ),
//     );
//   }

//   Widget _buildAssignmentsSection(UserModel teacher) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border(top: BorderSide(color: Colors.grey[300]!)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Assigned Grades & Divisions:',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//           ),
//           const SizedBox(height: 8),
//           if (teacher.gradeAssignments == null ||
//               teacher.gradeAssignments!.isEmpty)
//             const Text('No assignments', style: TextStyle(color: Colors.grey))
//           else
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: teacher.gradeAssignments!.entries.map((entry) {
//                 final grade = entry.key;
//                 final divisions = entry.value;
//                 return Chip(
//                   label: Text(
//                     divisions.isEmpty
//                         ? grade
//                         : '$grade (${divisions.join(", ")})',
//                   ),
//                   backgroundColor: const Color(0xFF4e3f8a).withOpacity(0.1),
//                 );
//               }).toList(),
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> _handleTeacherAction(
//     BuildContext context,
//     String action,
//     UserModel teacher,
//     CoordinatorProvider provider,
//   ) async {
//     switch (action) {
//       case 'edit':
//         _showEditAssignmentsDialog(context, teacher, provider);
//         break;
//       case 'deactivate':
//         _deactivateTeacher(context, teacher, provider);
//         break;
//       case 'reactivate':
//         _reactivateTeacher(context, teacher, provider);
//         break;
//     }
//   }

//   Future<void> _showEditAssignmentsDialog(
//     BuildContext context,
//     UserModel teacher,
//     CoordinatorProvider provider,
//   ) async {
//     final result = await showDialog<Map<String, List<String>>>(
//       context: context,
//       builder: (context) => _EditAssignmentsDialog(
//         teacher: teacher,
//         availableGrades: provider.availableGrades,
//       ),
//     );

//     if (result != null) {
//       try {
//         await provider.updateTeacher(teacher.uid, {'gradeAssignments': result});

//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Teacher assignments updated successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _deactivateTeacher(
//     BuildContext context,
//     UserModel teacher,
//     CoordinatorProvider provider,
//   ) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Deactivate Teacher'),
//         content: Text(
//           'Are you sure you want to deactivate ${teacher.name}?\n\n'
//           'They will no longer be able to log in.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Deactivate'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await provider.updateTeacher(teacher.uid, {'isActive': false});
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Teacher deactivated'),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//           );
//         }
//       }
//     }
//   }

//   Future<void> _reactivateTeacher(
//     BuildContext context,
//     UserModel teacher,
//     CoordinatorProvider provider,
//   ) async {
//     try {
//       await provider.updateTeacher(teacher.uid, {'isActive': true});
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Teacher reactivated'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
// }

// // Edit Assignments Dialog
// class _EditAssignmentsDialog extends StatefulWidget {
//   final UserModel teacher;
//   final List<String> availableGrades;

//   const _EditAssignmentsDialog({
//     required this.teacher,
//     required this.availableGrades,
//   });

//   @override
//   State<_EditAssignmentsDialog> createState() => _EditAssignmentsDialogState();
// }

// class _EditAssignmentsDialogState extends State<_EditAssignmentsDialog> {
//   late Map<String, List<String>> _tempAssignments;
//   final _divisionController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _tempAssignments = widget.teacher.gradeAssignments != null
//         ? Map.from(widget.teacher.gradeAssignments!)
//         : {};
//   }

//   @override
//   void dispose() {
//     _divisionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Edit Assignments - ${widget.teacher.name}'),
//       content: SizedBox(
//         width: double.maxFinite,
//         height: 500,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text('Select grades:'),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8,
//               children: widget.availableGrades.map((grade) {
//                 final isSelected = _tempAssignments.containsKey(grade);
//                 return FilterChip(
//                   label: Text(grade),
//                   selected: isSelected,
//                   onSelected: (selected) {
//                     setState(() {
//                       if (selected) {
//                         _tempAssignments[grade] = [];
//                       } else {
//                         _tempAssignments.remove(grade);
//                       }
//                     });
//                   },
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 16),
//             const Divider(),
//             const Text('Divisions:',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Expanded(
//               child: _tempAssignments.isEmpty
//                   ? const Center(child: Text('No grades selected'))
//                   : ListView(
//                       children: _tempAssignments.entries.map((entry) {
//                         return Card(
//                           child: ListTile(
//                             title: Text(entry.key),
//                             subtitle: Text(
//                               entry.value.isEmpty
//                                   ? 'All divisions'
//                                   : entry.value.join(', '),
//                             ),
//                             trailing: IconButton(
//                               icon: const Icon(Icons.add),
//                               onPressed: () =>
//                                   _showAddDivisionDialog(entry.key),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () => Navigator.pop(context, _tempAssignments),
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }

//   void _showAddDivisionDialog(String grade) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Add Division for $grade'),
//         content: TextField(
//           controller: _divisionController,
//           decoration: const InputDecoration(labelText: 'Division Name'),
//           textCapitalization: TextCapitalization.characters,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               _divisionController.clear();
//               Navigator.pop(context);
//             },
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final division = _divisionController.text.trim();
//               if (division.isNotEmpty) {
//                 setState(() {
//                   _tempAssignments[grade]!.add(division);
//                 });
//               }
//               _divisionController.clear();
//               Navigator.pop(context);
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/coordinator/teacher_management_screen_refactored.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/coordinator_provider.dart';
import '../../models/user_model.dart';

class TeacherManagementScreenRefactored extends StatelessWidget {
  const TeacherManagementScreenRefactored({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Management'),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          _buildStats(),
          Expanded(child: _buildTeachersList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => provider.setSearchQuery(''),
                        )
                      : null,
                ),
                onChanged: (value) => provider.setSearchQuery(value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: provider.selectedGrade,
                decoration: const InputDecoration(
                  labelText: 'Filter by Grade',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('All Grades')),
                  ...provider.availableGrades.map((grade) => DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      )),
                ],
                onChanged: (value) => provider.setGradeFilter(value),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats() {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        final filtered = provider.filteredTeachers;
        final total = provider.teachers;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${filtered.length} of ${total.length} teachers',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (provider.selectedGrade != null ||
                  provider.searchQuery.isNotEmpty)
                TextButton.icon(
                  onPressed: () => provider.clearFilters(),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Filters',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTeachersList() {
    return Consumer<CoordinatorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final teachers = provider.filteredTeachers;

        if (teachers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No teachers found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return _buildTeacherCard(context, teacher, provider);
          },
        );
      },
    );
  }

  Widget _buildTeacherCard(
    BuildContext context,
    UserModel teacher,
    CoordinatorProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              teacher.isActive ? const Color(0xFF4e3f8a) : Colors.grey,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          onSelected: (value) =>
              _handleTeacherAction(context, value, teacher, provider),
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
                    Text('Deactivate', style: TextStyle(color: Colors.red)),
                  ],
                ),
              )
            else
              const PopupMenuItem(
                value: 'reactivate',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Reactivate', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
          ],
        ),
        children: [
          _buildAssignmentsSection(teacher),
        ],
      ),
    );
  }

  Widget _buildAssignmentsSection(UserModel teacher) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Grades & Divisions:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (teacher.gradeAssignments == null ||
              teacher.gradeAssignments!.isEmpty)
            const Text('No assignments', style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: teacher.gradeAssignments!.entries.map((entry) {
                final grade = entry.key;
                final divisions = entry.value;
                return Chip(
                  label: Text(
                    divisions.isEmpty
                        ? grade
                        : '$grade (${divisions.join(", ")})',
                  ),
                  backgroundColor: const Color(0xFF4e3f8a).withOpacity(0.1),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _handleTeacherAction(
    BuildContext context,
    String action,
    UserModel teacher,
    CoordinatorProvider provider,
  ) async {
    switch (action) {
      case 'edit':
        _showEditAssignmentsDialog(context, teacher, provider);
        break;
      case 'deactivate':
        _deactivateTeacher(context, teacher, provider);
        break;
      case 'reactivate':
        _reactivateTeacher(context, teacher, provider);
        break;
    }
  }

  Future<void> _showEditAssignmentsDialog(
    BuildContext context,
    UserModel teacher,
    CoordinatorProvider provider,
  ) async {
    final result = await showDialog<Map<String, List<String>>>(
      context: context,
      builder: (context) => _EditAssignmentsDialog(
        teacher: teacher,
        availableGrades: provider.availableGrades,
      ),
    );

    if (result != null) {
      try {
        await provider.updateTeacher(teacher.uid, {'gradeAssignments': result});

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teacher assignments updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deactivateTeacher(
    BuildContext context,
    UserModel teacher,
    CoordinatorProvider provider,
  ) async {
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
        await provider.updateTeacher(teacher.uid, {'isActive': false});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teacher deactivated'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _reactivateTeacher(
    BuildContext context,
    UserModel teacher,
    CoordinatorProvider provider,
  ) async {
    try {
      await provider.updateTeacher(teacher.uid, {'isActive': true});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teacher reactivated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// Edit Assignments Dialog
class _EditAssignmentsDialog extends StatefulWidget {
  final UserModel teacher;
  final List<String> availableGrades;

  const _EditAssignmentsDialog({
    required this.teacher,
    required this.availableGrades,
  });

  @override
  State<_EditAssignmentsDialog> createState() => _EditAssignmentsDialogState();
}

class _EditAssignmentsDialogState extends State<_EditAssignmentsDialog> {
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Assignments - ${widget.teacher.name}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select grades:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.availableGrades.map((grade) {
                final isSelected = _tempAssignments.containsKey(grade);
                return FilterChip(
                  label: Text(grade),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tempAssignments[grade] = [];
                      } else {
                        _tempAssignments.remove(grade);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Divisions:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _tempAssignments.isEmpty
                  ? const Center(child: Text('No grades selected'))
                  : ListView(
                      children: _tempAssignments.entries.map((entry) {
                        return Card(
                          child: ListTile(
                            title: Text(entry.key),
                            subtitle: Text(
                              entry.value.isEmpty
                                  ? 'All divisions'
                                  : entry.value.join(', '),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () =>
                                  _showAddDivisionDialog(entry.key),
                            ),
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
          onPressed: () => Navigator.pop(context, _tempAssignments),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _showAddDivisionDialog(String grade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Division for $grade'),
        content: TextField(
          controller: _divisionController,
          decoration: const InputDecoration(labelText: 'Division Name'),
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
              if (division.isNotEmpty) {
                setState(() {
                  _tempAssignments[grade]!.add(division);
                });
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
}

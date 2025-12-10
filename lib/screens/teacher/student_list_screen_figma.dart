// import 'dart:math';

// import 'package:brainmoto_app/core/app_colors.dart';
// import 'package:brainmoto_app/core/app_text_styles.dart';
// import 'package:brainmoto_app/core/constant.dart';
// import 'package:brainmoto_app/core/helper.dart';
// import 'package:brainmoto_app/widgets/custom_search_bar.dart';
// import 'package:flutter/material.dart';

// class AssessByStudentScreenFigma extends StatefulWidget {
//   const AssessByStudentScreenFigma({super.key});

//   @override
//   State<AssessByStudentScreenFigma> createState() =>
//       _AssessByStudentScreenFigmaState();
// }

// enum StudentFilter { all, pending, completed, live }

// class _AssessByStudentScreenFigmaState extends State<AssessByStudentScreenFigma>
//     with SingleTickerProviderStateMixin {
//   late final TextEditingController _searchController;

//   final StudentFilter _currentFilter = StudentFilter.pending;

//   @override
//   void initState() {
//     super.initState();

//     _searchController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String value) {
//     // TODO: Implement search logic
//     debugPrint('Searching for: $value');
//   }

//   String get _filterButtonText {
//     switch (_currentFilter) {
//       case StudentFilter.all:
//         return 'All';
//       case StudentFilter.pending:
//         return 'Pending';
//       case StudentFilter.completed:
//         return 'Completed';
//       case StudentFilter.live:
//         return "Continue";
//     }
//   }

//   // void _showFilterBottomSheet() {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     shape: const RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   //     ),
//   //     builder: (context) => _FilterBottomSheet(
//   //       currentFilter: _currentFilter,
//   //       onFilterSelected: (filter) {
//   //         setState(() {
//   //           _currentFilter = filter;
//   //           _filterStudents();
//   //         });
//   //         Navigator.pop(context);
//   //       },
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     ResponsiveHelper.init(context);
//     return Scaffold(
//       appBar: AppBar(
//         // Use standard back behavior instead of a plain Icon (keeps accessibility)
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_sharp),
//           color: AppColors.enabledButtonGradientStart,
//           iconSize: 30,
//           onPressed: () => Navigator.of(context).maybePop(),
//         ),
//         title: Text(
//           "Nursery - Cattepillar",
//           style: AppTextStyles.gradeStyle,
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         foregroundColor: AppColors.enabledButtonGradientStart,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             CustomSearchBar(
//               controller: _searchController,
//               hintText: StringConstant.searchStudentName,
//               onChanged: _onSearchChanged,
//             ),
//             _buildFilterButton(),
//             _buildStudentInfo(),
//             _buildStudentInfo(),
//             _buildStudentInfowithPending(),
//             _buildStudentInfowithComplete(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: GestureDetector(
//           // onTap: _showFilterBottomSheet,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//             decoration: BoxDecoration(
//               color: AppColors.background,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: AppColors.divisionBackColor, width: 1),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.arrow_downward_sharp,
//                     size: 20, color: AppColors.secondaryText),
//                 Icon(Icons.filter_list,
//                     size: 18, color: AppColors.secondaryText),
//                 const SizedBox(width: 6),
//                 Text(_filterButtonText,
//                     style: AppTextStyles.secondary
//                         .copyWith(fontWeight: FontWeight.w500)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDivider() {
//     return Container(
//       height: 2.hp,
//       width: 2,
//       color: AppColors.nameDividerColor,
//     );
//   }

//   Widget _buildStudentInfo() {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   color: AppColors.divisionBackColor,
//                   borderRadius: BorderRadius.circular(40)),
//               child: Image.asset(AssetConstant.userProfile),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   overflow: TextOverflow.ellipsis,
//                   "Anvi Aniket Kulkarni",
//                   style: AppTextStyles.nameStyle,
//                 ),
//                 SizedBox(
//                   height: 0.5.hp,
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       "gasp09",
//                       style: AppTextStyles.secondary,
//                     ),
//                     SizedBox(
//                       width: 1.wp,
//                     ),
//                     _buildDivider(),
//                     SizedBox(
//                       width: 1.wp,
//                     ),
//                     Text(
//                       "4 out of 6",
//                       style: AppTextStyles.secondary
//                           .copyWith(color: AppColors.countinueTextColor),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//               decoration: BoxDecoration(
//                   color: AppColors.countinueTextColor.withValues(alpha: .2),
//                   borderRadius: BorderRadius.circular(30)),
//               child: Text(
//                 "Continue",
//                 style: AppTextStyles.secondary.copyWith(
//                     color: AppColors.countinueTextColor,
//                     fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 1.3.hp),
//           height: 0.1.hp,
//           width: double.infinity,
//           decoration: BoxDecoration(color: AppColors.disabledButtonText),
//         ),
//       ],
//     );
//   }

//   Widget _buildStudentInfowithPending() {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   color: AppColors.divisionBackColor,
//                   borderRadius: BorderRadius.circular(40)),
//               child: Image.asset(AssetConstant.userProfile),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   overflow: TextOverflow.ellipsis,
//                   "Anvi Aniket Kulkarni",
//                   style: AppTextStyles.nameStyle,
//                 ),
//                 SizedBox(
//                   height: 0.5.hp,
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       "gasp09",
//                       style: AppTextStyles.secondary,
//                     ),
//                     SizedBox(
//                       width: 1.wp,
//                     ),
//                     _buildDivider(),
//                     SizedBox(
//                       width: 1.wp,
//                     ),
//                     Text(
//                       "4 out of 6",
//                       style: AppTextStyles.secondary
//                           .copyWith(color: AppColors.pendingTextColor),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//               decoration: BoxDecoration(
//                   color: AppColors.pendingTextColor.withValues(alpha: .2),
//                   borderRadius: BorderRadius.circular(30)),
//               child: Text(
//                 "Pending",
//                 style: AppTextStyles.secondary.copyWith(
//                     color: AppColors.pendingTextColor,
//                     fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 1.3.hp),
//           height: 0.1.hp,
//           width: double.infinity,
//           decoration: BoxDecoration(color: AppColors.disabledButtonText),
//         ),
//       ],
//     );
//   }

//   Widget _buildStudentInfowithComplete() {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   color: AppColors.divisionBackColor,
//                   borderRadius: BorderRadius.circular(40)),
//               child: Image.asset(AssetConstant.userProfile),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   overflow: TextOverflow.ellipsis,
//                   "Anvi Aniket Kulkarni",
//                   style: AppTextStyles.nameStyle,
//                 ),
//                 SizedBox(
//                   height: 0.5.hp,
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       "gasp09",
//                       style: AppTextStyles.secondary,
//                     ),
//                     SizedBox(
//                       width: 1.wp,
//                     ),
//                     _buildDivider(),
//                     SizedBox(
//                       width: 1.wp,
//                     ),
//                     Text(
//                       "4 out of 6",
//                       style: AppTextStyles.secondary
//                           .copyWith(color: AppColors.completedTextColor),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
//               decoration: BoxDecoration(
//                   color: AppColors.completedTextColor.withValues(alpha: .2),
//                   borderRadius: BorderRadius.circular(30)),
//               child: Text(
//                 "Completed",
//                 style: AppTextStyles.secondary.copyWith(
//                     color: AppColors.completedTextColor,
//                     fontWeight: FontWeight.w500),
//               ),
//             ),
//           ],
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 1.3.hp),
//           height: 0.1.hp,
//           width: double.infinity,
//           decoration: BoxDecoration(color: AppColors.disabledButtonText),
//         ),
//       ],
//     );
//   }
// }

/*

below is refactored code

*/

import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:brainmoto_app/core/constant.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:brainmoto_app/widgets/custom_app_bar.dart';
import 'package:brainmoto_app/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Models
enum StudentStatus { continueStatus, pending, completed }

class Student {
  final String id;
  final String name;
  final int completedAssessments;
  final int totalAssessments;
  final StudentStatus status;

  Student({
    required this.id,
    required this.name,
    required this.completedAssessments,
    required this.totalAssessments,
    required this.status,
  });

  String get progressText => '$completedAssessments out of $totalAssessments';
}

enum StudentFilter { all, pending, completed, live }

class StudentListScreenFigma extends StatefulWidget {
  const StudentListScreenFigma({super.key});

  @override
  State<StudentListScreenFigma> createState() => _StudentListScreenFigmaState();
}

class _StudentListScreenFigmaState extends State<StudentListScreenFigma> {
  late final TextEditingController _searchController;
  StudentFilter _currentFilter = StudentFilter.pending;
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStudents() {
    // TODO: Replace with actual API call
    _students = [
      Student(
        id: 'gasp09',
        name: 'Anvi Aniket Kulkarni',
        completedAssessments: 4,
        totalAssessments: 6,
        status: StudentStatus.continueStatus,
      ),
      Student(
        id: 'gasp10',
        name: 'Laksh Rohan Badhe',
        completedAssessments: 2,
        totalAssessments: 6,
        status: StudentStatus.continueStatus,
      ),
      Student(
        id: 'gasp11',
        name: 'Vishwa Thorat',
        completedAssessments: 0,
        totalAssessments: 6,
        status: StudentStatus.pending,
      ),
      Student(
        id: 'gasp12',
        name: 'Samarth Kiran Ganjave',
        completedAssessments: 0,
        totalAssessments: 6,
        status: StudentStatus.pending,
      ),
      Student(
        id: 'gasp01',
        name: 'Raghav Anand Patil',
        completedAssessments: 6,
        totalAssessments: 6,
        status: StudentStatus.completed,
      ),
      Student(
        id: 'gasp02',
        name: 'Gargi Chetanraj Patil',
        completedAssessments: 6,
        totalAssessments: 6,
        status: StudentStatus.completed,
      ),
    ];
  }

  void _onSearchChanged(String value) {
    // TODO: Implement search logic
    debugPrint('Searching for: $value');
  }

  String get _filterButtonText {
    switch (_currentFilter) {
      case StudentFilter.all:
        return 'All';
      case StudentFilter.pending:
        return 'Pending';
      case StudentFilter.completed:
        return 'Completed';
      case StudentFilter.live:
        return 'Continue';
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterBottomSheet(
        currentFilter: _currentFilter,
        onFilterSelected: (filter) {
          setState(() {
            _currentFilter = filter;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'Nursery - Cattepillar',
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterButton(),
            Expanded(child: _buildStudentList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomSearchBar(
      controller: _searchController,
      hintText: StringConstant.searchStudentName,
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _showFilterBottomSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divisionBackColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_downward_sharp,
                  size: 20,
                  color: AppColors.secondaryText,
                ),
                Icon(
                  Icons.filter_list,
                  size: 18,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: 6),
                Text(
                  _filterButtonText,
                  style: AppTextStyles.secondary
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.builder(
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return _StudentCard(
          student: student,
          onTap: () => _navigateToStudentDetail(student),
        );
      },
    );
  }

  void _navigateToStudentDetail(Student student) {
    context.push('/assessment-question');
    // TODO: Navigate to student assessment detail
    debugPrint('Navigate to student: ${student.name}');
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final StudentFilter currentFilter;
  final Function(StudentFilter) onFilterSelected;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Students',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildFilterOption(
            context,
            'All Students',
            StudentFilter.all,
            Icons.people,
          ),
          _buildFilterOption(
            context,
            'Continue',
            StudentFilter.live,
            Icons.play_circle,
          ),
          _buildFilterOption(
            context,
            'Pending',
            StudentFilter.pending,
            Icons.pending_actions,
          ),
          _buildFilterOption(
            context,
            'Completed',
            StudentFilter.completed,
            Icons.check_circle,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String label,
    StudentFilter filter,
    IconData icon,
  ) {
    final isSelected = currentFilter == filter;
    return InkWell(
      onTap: () => onFilterSelected(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.enabledButtonGradientStart
                  : AppColors.appBarBackColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.black : Colors.grey[700],
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.enabledButtonGradientStart,
              ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAvatar(),
              Expanded(child: _buildStudentInfo()),
              _buildStatusBadge(),
            ],
          ),
        ),
        _buildDivider(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.divisionBackColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Image.asset(AssetConstant.userProfile),
    );
  }

  Widget _buildStudentInfo() {
    final statusConfig = _getStatusConfig();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            student.name,
            style: AppTextStyles.nameStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          SizedBox(height: 0.5.hp),
          Row(
            children: [
              Text(
                student.id,
                style: AppTextStyles.secondary,
              ),
              SizedBox(width: 1.wp),
              Container(
                height: 2.hp,
                width: 2,
                color: AppColors.nameDividerColor,
              ),
              SizedBox(width: 1.wp),
              Flexible(
                child: Text(
                  student.progressText,
                  style: AppTextStyles.secondary.copyWith(
                    color: statusConfig['progressColor'],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusConfig = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: (statusConfig['badgeColor'] as Color).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        statusConfig['text'] as String,
        style: AppTextStyles.secondary.copyWith(
          color: statusConfig['badgeColor'],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.3.hp),
      height: 0.1.hp,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.disabledButtonText,
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (student.status) {
      case StudentStatus.continueStatus:
        return {
          'text': 'Continue',
          'badgeColor': AppColors.countinueTextColor,
          'progressColor': AppColors.countinueTextColor,
        };
      case StudentStatus.pending:
        return {
          'text': 'Pending',
          'badgeColor': AppColors.pendingTextColor,
          'progressColor': AppColors.pendingTextColor,
        };
      case StudentStatus.completed:
        return {
          'text': 'Completed',
          'badgeColor': AppColors.completedTextColor,
          'progressColor': AppColors.completedTextColor,
        };
    }
  }
}

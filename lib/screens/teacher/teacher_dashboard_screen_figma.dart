// import 'package:brainmoto_app/core/app_colors.dart';
// import 'package:brainmoto_app/core/app_text_styles.dart';
// import 'package:brainmoto_app/core/constant.dart';
// import 'package:brainmoto_app/core/helper.dart';
// import 'package:brainmoto_app/widgets/custom_search_bar.dart';
// import 'package:flutter/material.dart';

// class TeacherDashboardScreen extends StatefulWidget {
//   const TeacherDashboardScreen({super.key});

//   @override
//   State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
// }

// class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
//   TextEditingController _searchController = TextEditingController();
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String value) {
//     print('Searching for: $value');
//     // Add your search logic here
//   }

//   @override
//   Widget build(BuildContext context) {
//     ResponsiveHelper.init(context);
//     return Scaffold(
//       body: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//             width: double.infinity,
//             decoration: BoxDecoration(
//                 color: AppColors.teacherDashboard.withValues(alpha: 1.0)),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       height: 38,
//                       width: 38,
//                       decoration: BoxDecoration(
//                           color:
//                               AppColors.profileLogoBack.withValues(alpha: 1.0),
//                           borderRadius: BorderRadius.circular(41)),
//                       child: Icon(
//                         Icons.person,
//                         color: AppColors.background,
//                       ),
//                     ),
//                     SizedBox(
//                       width: 3.wp,
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Hi, Mr. Anudip",
//                         ),
//                         Text(
//                           "Here’s your class overview",
//                           style: AppTextStyles.secondary,
//                         )
//                       ],
//                     )
//                   ],
//                 ),
//                 SizedBox(
//                   height: 3.hp,
//                 ),
//                 CustomSearchBar(
//                   controller: _searchController,
//                   hintText: StringConstant.teacherDashboardSearchHintText,
//                   onChanged: _onSearchChanged,
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: 10,
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   padding: EdgeInsets.all(10),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border:
//                         Border.all(color: AppColors.inputFieldBorder, width: 1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             "Nursery",
//                             style: AppTextStyles.gradeStyle,
//                           ),
//                           SizedBox(width: 2.wp),
//                           Container(
//                               padding: EdgeInsets.all(3),
//                               decoration: BoxDecoration(
//                                 color: AppColors.enabledButtonGradientStart
//                                     .withValues(alpha: .1),
//                                 borderRadius: BorderRadius.circular(6.wp),
//                               ),
//                               child: Text(
//                                 "Cattepillar",
//                                 style: AppTextStyles.divisionStyle,
//                               )),
//                           const Spacer(),
//                           Icon(
//                             Icons.arrow_forward_ios_rounded,
//                             color: AppColors.forwardIcon,
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 1.hp,
//                       ),
//                       Text(
//                         StringConstant.totalCountOfStudents,
//                         style: AppTextStyles.secondary
//                             .copyWith(color: AppColors.inputFieldText),
//                       ),
//                       SizedBox(
//                         height: 1.hp,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           _buildStatItem(
//                             count: 25.toString(),
//                             label: StringConstant.assessedText,
//                             color: AppColors.success,
//                           ),

//                           // Divider
//                           Container(
//                             height: 7.hp,
//                             width: 2,
//                             color: AppColors.dividerColor,
//                           ),

//                           // Pending
//                           _buildStatItem(
//                             count: 10.toString(),
//                             label: StringConstant.pendingText,
//                             color: AppColors.error,
//                           ),

//                           // Divider
//                           Container(
//                             height: 7.hp,
//                             width: 2,
//                             color: AppColors.dividerColor,
//                           ),

//                           // Total
//                           _buildStatItem(
//                             count: 35.toString(),
//                             label: StringConstant.totalText,
//                             color: AppColors.secondaryText,
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required String count,
//     required String label,
//     required Color color,
//   }) {
//     return Expanded(
//       child: Column(
//         children: [
//           Text(count, style: AppTextStyles.countDisplay.copyWith(color: color)),
//           SizedBox(height: 1.hp),
//           Text(
//             label,
//             style: AppTextStyles.secondary
//                 .copyWith(color: AppColors.searchBarText),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:brainmoto_app/core/constant.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:brainmoto_app/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // TODO: Implement search logic
    debugPrint('Searching for: $value');
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildClassList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.teacherDashboard.withValues(alpha: 1.0),
      ),
      child: Column(
        children: [
          _buildProfileSection(),
          SizedBox(height: 3.hp),
          CustomSearchBar(
            controller: _searchController,
            hintText: StringConstant.teacherDashboardSearchHintText,
            onChanged: _onSearchChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileAvatar(),
        SizedBox(width: 3.wp),
        _buildGreetingText(),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: AppColors.profileLogoBack.withValues(alpha: 1.0),
        borderRadius: BorderRadius.circular(41),
      ),
      child: Icon(
        Icons.person,
        color: AppColors.background,
      ),
    );
  }

  Widget _buildGreetingText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Hi, Mr. Anudip"),
        Text(
          "Here's your class overview",
          style: AppTextStyles.secondary,
        ),
      ],
    );
  }

  Widget _buildClassList() {
    // TODO: Replace with actual data source
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: 10,
      itemBuilder: (context, index) => _ClassCard(
        grade: "Nursery",
        division: "Cattepillar",
        assessedCount: 25,
        pendingCount: 10,
        totalCount: 35,
        onTap: () => _navigateToClassDetail(index),
      ),
    );
  }

  void _navigateToClassDetail(int index) {
    // TODO: Implement navigation
    context.push('/assessment-workflow');
    debugPrint('Navigate to class at index: $index');
  }
}

class _ClassCard extends StatelessWidget {
  final String grade;
  final String division;
  final int assessedCount;
  final int pendingCount;
  final int totalCount;
  final VoidCallback onTap;

  const _ClassCard({
    required this.grade,
    required this.division,
    required this.assessedCount,
    required this.pendingCount,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.inputFieldBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(),
            SizedBox(height: 1.hp),
            Text(
              StringConstant.totalCountOfStudents,
              style: AppTextStyles.secondary
                  .copyWith(color: AppColors.inputFieldText),
            ),
            SizedBox(height: 1.hp),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        Text(grade, style: AppTextStyles.gradeStyle),
        SizedBox(width: 2.wp),
        _buildDivisionBadge(),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.forwardIcon,
        ),
      ],
    );
  }

  Widget _buildDivisionBadge() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.enabledButtonGradientStart.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6.wp),
      ),
      child: Text(
        division,
        style: AppTextStyles.divisionStyle,
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatItem(
          count: assessedCount,
          label: StringConstant.assessedText,
          color: AppColors.success,
        ),
        _buildDivider(),
        _StatItem(
          count: pendingCount,
          label: StringConstant.pendingText,
          color: AppColors.error,
        ),
        _buildDivider(),
        _StatItem(
          count: totalCount,
          label: StringConstant.totalText,
          color: AppColors.secondaryText,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 7.hp,
      width: 2,
      color: AppColors.dividerColor,
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatItem({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: AppTextStyles.countDisplay.copyWith(color: color),
          ),
          SizedBox(height: 1.hp),
          Text(
            label,
            style: AppTextStyles.secondary
                .copyWith(color: AppColors.searchBarText),
          ),
        ],
      ),
    );
  }
}

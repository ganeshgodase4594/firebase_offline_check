import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:brainmoto_app/core/constant.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:flutter/material.dart';

// Model for assigned grades
class AssignedGrade {
  final String grade;
  final String division;

  AssignedGrade({
    required this.grade,
    required this.division,
  });

  String get displayText => '$grade - $division';
}

class ProfileScreenFigma extends StatefulWidget {
  const ProfileScreenFigma({super.key});

  @override
  State<ProfileScreenFigma> createState() => _ProfileScreenFigmaState();
}

class _ProfileScreenFigmaState extends State<ProfileScreenFigma> {
  final String userName = "Mr.Anudeep";
  final String userEmail = "anudeep@gmail.com";
  final List<AssignedGrade> assignedGrades = [
    AssignedGrade(grade: "Nursery", division: "Catepillar"),
    AssignedGrade(grade: "Jr.Kg", division: "Pupa 1"),
    AssignedGrade(grade: "Grade 1", division: "division A"),
  ];

  void _handleLogout() {
    // TODO: Implement logout logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(StringConstant.logoutText),
        content: const Text(StringConstant.areYouSure),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(StringConstant.cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform logout
              Navigator.pop(context);
              // Navigate to login screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.enabledButtonGradientStart,
            ),
            child: const Text(
              StringConstant.logoutText,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.enabledButtonGradientStart,
              AppColors.enabledButtonGradientEnd
            ],
          ),
        ),

        // Make the whole page scrollable to avoid overflow when text increases
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildBrainmotoLogo(),
                _buildProfileCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Profile',
          style: AppTextStyles.gradeStyle.copyWith(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildBrainmotoLogo() {
    // Constrain the logo so it doesn't push content down
    return Image.asset(
      AssetConstant.brainMotoLogoWhite,
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.wp),
      padding: EdgeInsets.all(5.wp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),

      // Use Column with mainAxisSize.min so the card only grows as needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileAvatar(),
          SizedBox(height: 2.hp),

          // User name (allow wrapping)
          Text(
            userName,
            textAlign: TextAlign.center,
            style: AppTextStyles.nameStyle.copyWith(
                fontSize: 22, color: AppColors.enabledButtonGradientStart),
          ),

          SizedBox(height: 0.8.hp),

          // Email (wrap if long)
          Text(
            userEmail,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              overflow: TextOverflow.visible,
            ),
          ),

          SizedBox(height: 1.5.hp),
          _buildDivider(),
          SizedBox(height: 2.hp),

          _buildAssignedGradesSection(),

          SizedBox(height: 2.hp),
          _buildDivider(),
          SizedBox(height: 2.hp),

          // Logout button (full width)
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.enabledButtonGradientStart,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 50,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: AppColors.dividerColor,
    );
  }

  Widget _buildAssignedGradesSection() {
    return Column(
      children: [
        Text(
          StringConstant.assignedGrade,
          style: AppTextStyles.nameStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.hp),

        // Render grades — each row's text is inside Flexible to allow wrapping
        Column(
          children:
              assignedGrades.map((grade) => _buildGradeItem(grade)).toList(),
        ),
      ],
    );
  }

  Widget _buildGradeItem(AssignedGrade grade) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.hp),
      child: Row(
        // allow items to start from left and wrap if needed

        children: [
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: AppColors.enabledButtonGradientStart,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.wp),

          // Flexible ensures this long text wraps instead of overflowing
          Flexible(
            child: Text(grade.displayText, style: AppTextStyles.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(1.2.hp),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.enabledButtonGradientStart,
              AppColors.enabledButtonGradientEnd
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: const Text(
            StringConstant.logoutText,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

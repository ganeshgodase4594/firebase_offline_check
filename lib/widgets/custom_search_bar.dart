// Custom Search Bar Widget
import 'package:flutter/material.dart';
import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:brainmoto_app/core/constant.dart';
import 'package:brainmoto_app/core/helper.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(
          color: AppColors.teacherDashboard,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        // style: AppTextStyles.searchBarText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.inputFieldHint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 2.wp,
            vertical: 1.5.hp,
          ),
          // Image as prefix icon
          prefixIcon: Padding(
            padding: EdgeInsets.all(1.wp),
            child: Image.asset(
              AssetConstant.searchImage,
              // width: 8.wp,
              // height: 8.wp,
              // fit: BoxFit.contain,
              // Optional: tint the image
            ),
          ),
          // Optional: Clear button as suffix icon
        ),
      ),
    );
  }
}

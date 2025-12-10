// ============================================
// app_text_styles.dart
// ============================================

import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Text Styles using Aptos and Poppins fonts from Google Fonts
class AppTextStyles {
  // Headings - Using Aptos (Google Fonts)
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 24.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // Body Text - Using Poppins (Google Fonts)
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  // Button Text
  static TextStyle buttonEnabled = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.enabledButtonText,
  );

  static TextStyle buttonDisabled = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.disabledButtonText,
  );

  static TextStyle gradeStyle = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.enabledButtonGradientStart,
  );

  // Input Field Text
  static TextStyle inputField = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );

  static TextStyle nameStyle = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static TextStyle inputFieldHint = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.inputFieldText,
  );

  // Search Bar Text
  static TextStyle searchBar = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.searchBarText,
  );

  // Caption/Label
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  // Secondary Text
  static TextStyle secondary = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  static TextStyle divisionStyle = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.enabledButtonGradientEnd,
  );

  //count display

  static TextStyle countDisplay =
      GoogleFonts.poppins(fontSize: 26.sp, fontWeight: FontWeight.bold);
}

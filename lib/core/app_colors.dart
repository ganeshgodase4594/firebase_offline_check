// app_colors.dart
import 'package:flutter/material.dart';

/// App Color Palette
class AppColors {
  // Text Colors
  static const Color primaryText = Color(0xFF1E1E1E);
  static const Color secondaryText = Color(0xFF5A5A6E);
  static const Color inputFieldText = Color(0xFFA4A3B4);
  static const Color searchBarText = Color(0xFF878787);

  // Button Colors - Disabled
  static const Color disabledButtonText = Color(0xFFD9D6EA);
  static const Color disabledButton = Color(0xFFA4A3B4);

  // Button Colors - Enabled
  static const Color enabledButtonText = Color(0xFFFFFFFF);
  static const Color enabledButtonGradientStart = Color(0xFF4E3F8A);
  static const Color enabledButtonGradientEnd = Color(0xFF6F5DCB);

  // Additional utility colors (add as needed)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  static const Color inputFieldBack = Color(0xFFE2E0F0);
  static const Color inputFieldBorder = Color(0XFFE2E0F0);
  static const Color profileLogoBack = Color(0xFF6750A4);
  static const Color divisionBackColor = Color(0xFFF2EFFF);
  static const Color forwardIcon = Color(0xFF8B82B8);
  static const Color appBarBackColor = Color(0xFFF5F4FA);

  // Add more colors as your design grows
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF3CB371);
  static const Color warning = Color(0xFFFB8C00);
  static const Color info = Color(0xFF1E88E5);
  static const Color dividerColor = Color(0xFFC5BFF3);
  static const Color nameDividerColor = Color(0xFFF5D527);
  static const Color countinueTextColor = Color(0xFF3498DB);
  static const Color pendingTextColor = Color(0xFFF5A623);
  static const Color completedTextColor = Color(0xFF3CB371);
  static const Color progressBarBack = Color(0xFFE3E6EC);
  static const Color timerDisplayBack = Color(0xFFF8F7FB);

  // Background colors (optional)
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color teacherDashboard = Color(0xFFE8ECF4);

  // Gradient for enabled button
  static LinearGradient get enabledButtonGradient => const LinearGradient(
        colors: [enabledButtonGradientStart, enabledButtonGradientEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
}

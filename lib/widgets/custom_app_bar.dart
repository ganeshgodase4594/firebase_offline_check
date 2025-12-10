import 'package:flutter/material.dart';
import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          color: AppColors.enabledButtonGradientStart,
          iconSize: 30,
          onPressed: () {
            // If there is a navigator history entry, pop it.
            if (Navigator.of(context).canPop()) {
              context.pop(); // GoRouter's pop (preferred)
              return;
            }

            // Otherwise, we are at a top-level route (shell). Send user to dashboard or do nothing.
            // Use go to replace (prevents crash) — adjust path to your desired fallback.
            context.go('/dashboard');
          }),
      title: Text(
        title,
        style: AppTextStyles.gradeStyle,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

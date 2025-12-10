import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:flutter/material.dart';

class AssessmentCard extends StatelessWidget {
  final String assetPath;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const AssessmentCard({
    super.key,
    required this.assetPath,
    required this.title,
    required this.description,
    this.onTap,
  });

  static const _cardBorderRadius = 20.0;
  static const _innerRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
      border: Border.all(color: AppColors.inputFieldBorder, width: 1),
      borderRadius: BorderRadius.circular(_cardBorderRadius),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        decoration: cardDecoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // image container
            Container(
              margin: const EdgeInsets.all(15),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.divisionBackColor.withValues(alpha: .9),
                borderRadius: BorderRadius.circular(_innerRadius),
              ),
              child: Image.asset(
                assetPath,
                fit: BoxFit.fitHeight,
                // you can provide height/width if necessary:
                // height: 10.wp,
                // width: 8.wp,
              ),
            ),
            // text column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 18.sp),
                    ),
                    SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.inputFieldHint
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ),
            // forward icon
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.forwardIcon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

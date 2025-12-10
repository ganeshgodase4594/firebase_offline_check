import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:brainmoto_app/core/constant.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:brainmoto_app/widgets/choose_assessment_type_container.dart';
import 'package:brainmoto_app/widgets/custom_app_bar.dart';
import 'package:brainmoto_app/widgets/custom_assessmentcard_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChooseAssessmentTypeScreen extends StatefulWidget {
  const ChooseAssessmentTypeScreen({super.key});

  @override
  State<ChooseAssessmentTypeScreen> createState() =>
      _ChooseAssessmentTypeScreenState();
}

class _ChooseAssessmentTypeScreenState
    extends State<ChooseAssessmentTypeScreen> {
  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: "Nursery-Cattepilar",
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              StringConstant.chooseAssessmentType,
              style: AppTextStyles.h3,
            ),
            Expanded(
                child: ListView(
              children: [
                AssessmentTypeCard(
                  assetPath: AssetConstant.userProfile,
                  title: StringConstant.locoMeterAssessment,
                  onTap: () => context.push('/studentlist'),
                ),
                AssessmentTypeCard(
                    assetPath: AssetConstant.skillImage,
                    title: StringConstant.coordinationAssessment),
                AssessmentTypeCard(
                    assetPath: AssetConstant.skillImage,
                    title: StringConstant.objectControlAssessment),
                AssessmentTypeCard(
                    assetPath: AssetConstant.skillImage,
                    title: StringConstant.bodyManageAssessment),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

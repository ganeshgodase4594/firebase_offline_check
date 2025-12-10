// import 'package:brainmoto_app/core/app_colors.dart';
// import 'package:brainmoto_app/core/app_text_styles.dart';
// import 'package:brainmoto_app/core/constant.dart';
// import 'package:brainmoto_app/core/helper.dart';
// import 'package:flutter/material.dart';

// class AssessmentWorkflowScreenFigma extends StatefulWidget {
//   const AssessmentWorkflowScreenFigma({super.key});

//   @override
//   State<AssessmentWorkflowScreenFigma> createState() =>
//       _AssessmentWorkflowScreenFigmaState();
// }

// class _AssessmentWorkflowScreenFigmaState
//     extends State<AssessmentWorkflowScreenFigma> {
//   @override
//   Widget build(BuildContext context) {
//     ResponsiveHelper.init(context);
//     return Scaffold(
//       appBar: AppBar(
//           title: Row(
//         children: [
//           Icon(
//             Icons.arrow_back_sharp,
//             color: AppColors.enabledButtonGradientStart,
//             size: 30,
//           ),
//           SizedBox(
//             width: 2.wp,
//           ),
//           Text(
//             "Nursery - Cattepillar",
//             style: AppTextStyles.gradeStyle,
//           )
//         ],
//       )),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               StringConstant.assessmentWorkFlowTitle,
//               style: AppTextStyles.h4,
//             ),
//             SizedBox(
//               height: 2.hp,
//             ),
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.inputFieldBorder, width: 1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     margin: EdgeInsets.all(15),
//                     padding: EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                         color:
//                             AppColors.divisionBackColor.withValues(alpha: .9),
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Image.asset(
//                       AssetConstant.userProfile,
//                       // height: 10.wp,
//                       // width: 8.wp,
//                       fit: BoxFit.fitHeight,
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Text(
//                           StringConstant.assessByStudent,
//                           style: AppTextStyles.bodyMedium
//                               .copyWith(fontSize: 18.sp),
//                         ),
//                         Text(
//                           StringConstant.assessByStudentDesc,
//                           textAlign: TextAlign.left,
//                           maxLines: 2, // Optional: limit lines
//                           overflow: TextOverflow.ellipsis,
//                           style: AppTextStyles.inputFieldHint
//                               .copyWith(color: AppColors.secondaryText),
//                         )
//                       ],
//                     ),
//                   ),
//                   Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     color: AppColors.forwardIcon,
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               margin: EdgeInsets.symmetric(vertical: 3.hp),
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 border: Border.all(color: AppColors.inputFieldBorder, width: 1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     margin: EdgeInsets.all(15),
//                     padding: EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                         color:
//                             AppColors.divisionBackColor.withValues(alpha: .9),
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Image.asset(
//                       AssetConstant.skillImage,
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Text(
//                           StringConstant.assessBySkill,
//                           style: AppTextStyles.bodyMedium
//                               .copyWith(fontSize: 18.sp),
//                         ),
//                         Text(
//                           StringConstant.assessBySkillDesc,
//                           textAlign: TextAlign.left,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: AppTextStyles.inputFieldHint
//                               .copyWith(color: AppColors.secondaryText),
//                         )
//                       ],
//                     ),
//                   ),
//                   Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     color: AppColors.forwardIcon,
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:brainmoto_app/core/app_colors.dart';
import 'package:brainmoto_app/core/app_text_styles.dart';
import 'package:brainmoto_app/core/constant.dart';
import 'package:brainmoto_app/core/helper.dart';
import 'package:brainmoto_app/widgets/custom_app_bar.dart';
import 'package:brainmoto_app/widgets/custom_assessmentcard_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssessmentWorkflowScreenFigma extends StatelessWidget {
  const AssessmentWorkflowScreenFigma({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: "Nursery-Cattepilar"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringConstant.assessmentWorkFlowTitle,
              style: AppTextStyles.h4,
            ),
            SizedBox(height: 2.hp),
            // Use ListView for content so it scrolls on smaller screens
            Expanded(
              child: ListView(
                children: [
                  AssessmentCard(
                    assetPath: AssetConstant.userProfile,
                    title: StringConstant.assessByStudent,
                    description: StringConstant.assessByStudentDesc,
                    onTap: () {
                      // navigate or handle tap
                      context.push('/studentlist');
                    },
                  ),
                  AssessmentCard(
                    assetPath: AssetConstant.skillImage,
                    title: StringConstant.assessBySkill,
                    description: StringConstant.assessBySkillDesc,
                    onTap: () {
                      context.push('/assessment-type');
                      // navigate or handle tap
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

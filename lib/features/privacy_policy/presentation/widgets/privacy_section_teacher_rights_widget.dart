import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_section_header_widget.dart';
import 'package:moean/features/privacy_policy/presentation/widgets/privacy_teacher_right_item_widget.dart';

class PrivacySectionTeacherRightsWidget extends StatelessWidget {
  const PrivacySectionTeacherRightsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrivacySectionHeaderWidget(
            title: appTranslation().get('privacy_sec7_title'),
            subtitle: appTranslation().get('privacy_sec7_subtitle'),
            icon: Icons.person_outline_rounded,
            tag: appTranslation().get('privacy_sec7_tag'),
          ),
          verticalSpace16,
          Text(
            appTranslation().get('privacy_sec7_intro'),
            style: TextStylesManager.regular13.copyWith(
              color: ColorsManager.mainText,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          verticalSpace14,
          PrivacyTeacherRightItemWidget(
            number: 1,
            text: appTranslation().get('privacy_sec7_item1'),
          ),
          verticalSpace10,
          PrivacyTeacherRightItemWidget(
            number: 2,
            text: appTranslation().get('privacy_sec7_item2'),
          ),
          verticalSpace10,
          PrivacyTeacherRightItemWidget(
            number: 3,
            text: appTranslation().get('privacy_sec7_item3'),
          ),
        ],
      ),
    );
  }
}

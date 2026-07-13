import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class MoyasarCardNameWidget extends StatelessWidget {
  final TextEditingController controller;
  const MoyasarCardNameWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              appTranslation().get('pay_name_on_card'),
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.mainText,
              ),
            ),
            Text(
              appTranslation().get('field_required'),
              style: TextStylesManager.medium12.copyWith(
                color: ColorsManager.errorColor,
              ),
            ),
          ],
        ),
        verticalSpace8,
        PrimaryTextField(
          controller: controller,
          hint: appTranslation().get('pay_name_on_card'),
          keyboardType: TextInputType.name,
          fillColor: ColorsManager.surfacePrimary,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return appTranslation().get('field_required');
            }
            return null;
          },
        ),
      ],
    );
  }
}

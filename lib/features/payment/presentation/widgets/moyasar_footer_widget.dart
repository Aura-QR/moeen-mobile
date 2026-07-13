import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class MoyasarFooterWidget extends StatelessWidget {
  const MoyasarFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          appTranslation().get('pay_service_provided_by'),
          style: TextStylesManager.medium12.copyWith(
            color: ColorsManager.textSecondary,
          ),
        ),
        verticalSpace8,
        Text(
          appTranslation().get('pay_test_mode_warning'),
          textAlign: TextAlign.center,
          style: TextStylesManager.medium12.copyWith(
            color: ColorsManager.errorColor,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class ManualExamScreen extends StatelessWidget {
  const ManualExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: ColorsManager.mainText,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            appTranslation().get('home_worksheets'),
            style: TextStylesManager.bold18.copyWith(
              color: ColorsManager.mainText,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_rounded,
                size: 80,
                color: ColorsManager.primaryColor.withValues(alpha: 0.5),
              ),
              verticalSpace16,
              Text(
                'قريباً',
                style: TextStylesManager.bold24.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
              verticalSpace8,
              Text(
                'سيتم توفير ميزة الاختبار اليدوي قريباً',
                style: TextStylesManager.regular14.copyWith(
                  color: ColorsManager.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

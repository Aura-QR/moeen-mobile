import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class MoyasarCardDetailsWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController numberController;
  final TextEditingController expiryController;
  final TextEditingController cvcController;

  const MoyasarCardDetailsWidget({
    super.key,
    required this.nameController,
    required this.numberController,
    required this.expiryController,
    required this.cvcController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اسم حامل البطاقة',
          style: TextStylesManager.bold14.copyWith(
            color: ColorsManager.primaryColor,
          ),
        ),
        verticalSpace8,
        Container(
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorsManager.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextFormField(
              controller: nameController,
              keyboardType: TextInputType.name,
              style: TextStylesManager.medium16,
              decoration: InputDecoration(
                hintText: 'الاسم كما هو مطبوع على البطاقة',
                hintStyle: TextStylesManager.regular16.copyWith(
                  color: ColorsManager.textSecondary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        verticalSpace16,
        Text(
          'رقم البطاقة',
          style: TextStylesManager.bold14.copyWith(
            color: ColorsManager.primaryColor,
          ),
        ),
        verticalSpace8,
        Container(
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorsManager.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      style: TextStylesManager.medium16,
                      decoration: InputDecoration(
                        hintText: '1234 5678 9101 1121',
                        hintStyle: TextStylesManager.regular16.copyWith(
                          color: ColorsManager.textSecondary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                horizontalSpace8,
                // Payment Icons
                Row(
                  children: [
                    _buildBrandIcon('VISA', Colors.blue),
                    horizontalSpace4,
                    _buildBrandIcon('MC', Colors.red),
                    horizontalSpace4,
                    _buildBrandIcon('mada', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ),
        verticalSpace16,
        Row(
          children: [
            Expanded(
              child: Text(
                'تاريخ الانتهاء',
                style: TextStylesManager.bold14.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
            ),
            horizontalSpace16,
            Expanded(
              child: Text(
                'رمز الأمان',
                style: TextStylesManager.bold14.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
            ),
          ],
        ),
        verticalSpace8,
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ColorsManager.surfacePrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      controller: expiryController,
                      keyboardType: TextInputType.datetime,
                      style: TextStylesManager.medium16,
                      decoration: InputDecoration(
                        hintText: 'MM/YY',
                        hintStyle: TextStylesManager.regular16.copyWith(
                          color: ColorsManager.textSecondary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            horizontalSpace16,
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ColorsManager.surfacePrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      controller: cvcController,
                      keyboardType: TextInputType.number,
                      style: TextStylesManager.medium16,
                      decoration: InputDecoration(
                        hintText: 'CVC',
                        hintStyle: TextStylesManager.regular16.copyWith(
                          color: ColorsManager.textSecondary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandIcon(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: ColorsManager.borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}


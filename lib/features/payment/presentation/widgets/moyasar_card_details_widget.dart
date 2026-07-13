import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class MoyasarCardDetailsWidget extends StatelessWidget {
  final TextEditingController numberController;
  final TextEditingController expiryController;
  final TextEditingController cvcController;

  const MoyasarCardDetailsWidget({
    super.key,
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
          appTranslation().get('pay_card_info'),
          style: TextStylesManager.bold14.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        verticalSpace8,
        Container(
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorsManager.borderColor),
          ),
          child: Column(
            children: [
              // Card Number
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
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
              Divider(height: 1, color: ColorsManager.borderColor),
              // Expiry and CVC
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextFormField(
                          controller: expiryController,
                          keyboardType: TextInputType.datetime,
                          style: TextStylesManager.medium16,
                          decoration: InputDecoration(
                            hintText: appTranslation().get('pay_expiry_date'),
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
                    VerticalDivider(width: 1, color: ColorsManager.borderColor),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextFormField(
                          controller: cvcController,
                          keyboardType: TextInputType.number,
                          style: TextStylesManager.medium16,
                          decoration: InputDecoration(
                            hintText: appTranslation().get('pay_cvc'),
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
                  ],
                ),
              ),
            ],
          ),
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

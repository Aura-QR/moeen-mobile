import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ActionButtonWidget extends StatelessWidget {
  final String titleKey;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final bool isOutlined;
  final VoidCallback? onTap;

  const ActionButtonWidget({
    super.key,
    required this.titleKey,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.isOutlined = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
      decoration: BoxDecoration(
        color: backgroundColor ?? ColorsManager.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOutlined ? color : (backgroundColor == null ? ColorsManager.borderLightGray : Colors.transparent),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          verticalSpace4,
          Text(
            appTranslation().get(titleKey),
            style: TextStylesManager.regular10.copyWith(
              color: backgroundColor != null ? ColorsManager.white : color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
    );
  }
}

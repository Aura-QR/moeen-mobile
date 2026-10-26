import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ExtractionSourceButtonItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ExtractionSourceButtonItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsManager.borderLightGray),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ColorsManager.primaryColor, size: 24),
            verticalSpace6,
            Text(
              label,
              style: TextStylesManager.medium12.copyWith(
                color: ColorsManager.mainText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

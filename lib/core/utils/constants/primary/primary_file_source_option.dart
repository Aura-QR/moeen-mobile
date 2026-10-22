import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// One tile in a [PrimaryFileSourceSheet].
class PrimaryFileSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PrimaryFileSourceOption({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: ColorsManager.primaryColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: ColorsManager.primaryColor, size: 28),
            verticalSpace8,
            Text(
              label,
              style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
            ),
          ],
        ),
      ),
    );
  }
}

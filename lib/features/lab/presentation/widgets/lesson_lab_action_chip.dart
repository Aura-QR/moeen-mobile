import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// Compact action chip used for lesson-level Virtual Lab actions
/// («تجارب الدرس», «أنشئ تجربة», «اطلب تجربة»).
class LessonLabActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const LessonLabActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor =
        isPrimary ? ColorsManager.primaryColor : ColorsManager.mainText;
    final bgColor = isPrimary
        ? ColorsManager.primaryColor.withValues(alpha: 0.1)
        : ColorsManager.surfacePrimary;
    final borderColor = isPrimary
        ? ColorsManager.primaryColor.withValues(alpha: 0.3)
        : ColorsManager.borderLightGray;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: fgColor),
            horizontalSpace4,
            Text(
              label,
              style: TextStylesManager.bold12.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }
}

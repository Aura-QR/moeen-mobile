import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class HomeResourceCardWidget extends StatelessWidget {
  final String typeKey;
  final String titleKey;
  final String subjectKey;
  final String gradeKey;
  final double usesCount;
  final Color typeColor;
  final Color typeBgColor;
  final IconData typeIcon;

  const HomeResourceCardWidget({
    super.key,
    required this.typeKey,
    required this.titleKey,
    required this.subjectKey,
    required this.gradeKey,
    required this.usesCount,
    required this.typeColor,
    required this.typeBgColor,
    required this.typeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final t = appTranslation();
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsManager.borderColor.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ResourceIconBox(
                  icon: typeIcon,
                  color: typeColor,
                  bgColor: typeBgColor,
                ),
                _TypeBadge(
                  label: t.get(typeKey),
                  color: typeColor,
                  bgColor: typeBgColor,
                ),
              ],
            ),
            verticalSpace12,
            Text(
              t.get(titleKey),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.textPrimary,
                height: 1.4,
              ),
            ),
            verticalSpace6,
            Text(
              '${t.get(subjectKey)} • ${t.get(gradeKey)}',
              textAlign: TextAlign.right,
              style: TextStylesManager.regular12.copyWith(
                color: ColorsManager.textBody,
              ),
            ),
            verticalSpace12,
            const Divider(height: 1),
            verticalSpace10,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionIconButton(icon: Icons.download_outlined),
                horizontalSpace8,
                Text(
                  '${usesCount.toStringAsFixed(1)} ${t.get('k_uses')}',
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.textBody,
                  ),
                ),
                _ActionIconButton(icon: Icons.bookmark_border_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _ResourceIconBox({
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _TypeBadge({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStylesManager.medium10.copyWith(color: color),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;

  const _ActionIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: ColorsManager.backgroundColorLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ColorsManager.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: ColorsManager.primaryColor,
      ),
    );
  }
}

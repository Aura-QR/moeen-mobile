import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ChoseAppOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final bool badgeActive;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const ChoseAppOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeActive,
    required this.isSelected,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSelected
        ? ColorsManager.primaryColor
        : ColorsManager.borderColor;

    final Color iconBg = isSelected
        ? ColorsManager.primaryColor.withValues(alpha: 0.12)
        : ColorsManager.surfacePrimary;

    final Color iconColor = isSelected
        ? ColorsManager.primaryColor
        : ColorsManager.placeholder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? ColorsManager.primaryColor.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isSelected ? 24 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: ColorsManager.primaryColor.withValues(alpha: 0.08),
          highlightColor: ColorsManager.primaryColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 26,
                  ),
                ),
                horizontalSpace12,
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            title,
                            style: TextStylesManager.bold16.copyWith(
                              color: isDisabled
                                  ? ColorsManager.placeholder
                                  : ColorsManager.mainText,
                            ),
                          ),
                          _BadgeChip(
                            label: badge,
                            active: badgeActive,
                          ),
                        ],
                      ),
                      verticalSpace6,
                      Text(
                        subtitle,
                        style: TextStylesManager.regular13.copyWith(
                          color: ColorsManager.secondaryText,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                horizontalSpace10,
                // Radio indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? ColorsManager.primaryColor
                          : ColorsManager.borderColor,
                      width: isSelected ? 6 : 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final bool active;

  const _BadgeChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active
            ? ColorsManager.primaryColor.withValues(alpha: 0.12)
            : ColorsManager.secondaryColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStylesManager.bold10.copyWith(
          color: active
              ? ColorsManager.primaryColor
              : ColorsManager.secondaryColor,
        ),
      ),
    );
  }
}

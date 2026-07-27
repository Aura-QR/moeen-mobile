import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class SavedReportsHeaderWidget extends StatelessWidget {
  final VoidCallback onRefresh;

  const SavedReportsHeaderWidget({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top action buttons (Close X and Refresh)
            Row(
              children: [
                _HeaderIconButton(
                  icon: Icons.close_rounded,
                  onTap: () => context.pop(),
                ),
                horizontalSpace8,
                _HeaderIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: onRefresh,
                ),
              ],
            ),
            // Saved Reports Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appTranslation().get('saved_reports_title'),
                    style: TextStylesManager.bold12.copyWith(
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                  horizontalSpace6,
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: ColorsManager.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        verticalSpace16,
        Text(
          appTranslation().get('saved_reports_subtitle'),
          style: TextStylesManager.bold24.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        verticalSpace6,
        Text(
          appTranslation().get('saved_reports_desc'),
          style: TextStylesManager.regular14.copyWith(
            color: ColorsManager.secondaryText,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          shape: BoxShape.circle,
          border: Border.all(
            color: ColorsManager.borderColor.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: ColorsManager.mainText,
        ),
      ),
    );
  }
}

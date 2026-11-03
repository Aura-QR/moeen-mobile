import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class AdminLabTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final int experimentsCount;
  final int reportsCount;
  final int requestsCount;

  const AdminLabTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.experimentsCount = 0,
    this.reportsCount = 0,
    this.requestsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: appTranslation().get('admin_lab_tab_experiments'),
              count: experimentsCount,
              isSelected: selectedIndex == 0,
              onTap: () => onTabSelected(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              title: appTranslation().get('admin_lab_tab_reports'),
              count: reportsCount,
              isSelected: selectedIndex == 1,
              isAlert: reportsCount > 0,
              onTap: () => onTabSelected(1),
            ),
          ),
          Expanded(
            child: _TabButton(
              title: appTranslation().get('admin_lab_tab_requests'),
              count: requestsCount,
              isSelected: selectedIndex == 2,
              onTap: () => onTabSelected(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final int count;
  final bool isSelected;
  final bool isAlert;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.count,
    required this.isSelected,
    this.isAlert = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStylesManager.medium12.copyWith(
                color: isSelected ? ColorsManager.white : ColorsManager.mainText,
              ),
            ),
            if (count > 0) ...[
              horizontalSpace4,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorsManager.white.withValues(alpha: 0.25)
                      : (isAlert ? ColorsManager.errorColor : ColorsManager.placeholder.withValues(alpha: 0.2)),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStylesManager.bold10.copyWith(
                    color: isSelected ? ColorsManager.white : (isAlert ? ColorsManager.white : ColorsManager.secondaryText),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

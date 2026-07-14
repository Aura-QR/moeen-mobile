import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class MyExamsHeaderWidget extends StatelessWidget {
  final String selectedTab;
  final Function(String) onTabChanged;
  final Function(String) onSearchChanged;

  const MyExamsHeaderWidget({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorsManager.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: ColorsManager.borderLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: appTranslation().get('search_exam_title'),
                  hintStyle: TextStylesManager.regular14.copyWith(color: ColorsManager.placeholder),
                  prefixIcon: Icon(Icons.search, color: ColorsManager.placeholder),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          horizontalSpace16,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTab('all', appTranslation().get('all')),
              horizontalSpace8,
              _buildTab('draft', appTranslation().get('draft')),
              horizontalSpace8,
              _buildTab('published', appTranslation().get('published')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String tabKey, String label) {
    final isSelected = selectedTab == tabKey;
    return GestureDetector(
      onTap: () => onTabChanged(tabKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor : ColorsManager.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderLight,
          ),
        ),
        child: Text(
          label,
          style: isSelected
              ? TextStylesManager.bold14.copyWith(color: ColorsManager.white)
              : TextStylesManager.medium14.copyWith(color: ColorsManager.placeholder),
        ),
      ),
    );
  }
}

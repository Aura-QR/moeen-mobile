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
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
          //    color: ColorsManager.borderLightGray.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
              decoration: InputDecoration(
                hintText: appTranslation().get('search_exam_title'),
                hintStyle: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                prefixIcon: Icon(Icons.search, color: ColorsManager.secondaryText),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          verticalSpace16,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTab('all', appTranslation().get('all')),
                horizontalSpace8,
                _buildTab('draft', appTranslation().get('draft')),
                horizontalSpace8,
                _buildTab('published', appTranslation().get('published')),
              ],
            ),
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
          color: isSelected ? ColorsManager.primaryColor : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.borderLightGray,
          ),
        ),
        child: Text(
          label,
          style: isSelected
              ? TextStylesManager.bold14.copyWith(color: Colors.white)
              : TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
        ),
      ),
    );
  }
}

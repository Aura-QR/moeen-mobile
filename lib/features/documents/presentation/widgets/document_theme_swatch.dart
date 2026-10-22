import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';

class DocumentThemeSwatch extends StatelessWidget {
  final DocumentTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const DocumentThemeSwatch({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? theme.color : ColorsManager.borderColor, width: 2),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(color: theme.color, shape: BoxShape.circle),
              child: isSelected ? const Icon(Icons.check_rounded, color: ColorsManager.white, size: 22) : null,
            ),
          ),
          verticalSpace6,
          Text(
            appTranslation().get(theme.labelKey),
            style: TextStylesManager.medium12.copyWith(
              color: isSelected ? ColorsManager.mainText : ColorsManager.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

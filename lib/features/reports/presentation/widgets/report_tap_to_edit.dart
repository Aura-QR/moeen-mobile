import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

/// A text shown as it prints, opening its editor on tap. Empty shows
/// [placeholderKey] in grey.
class ReportTapToEdit extends StatelessWidget {
  final String text;
  final String placeholderKey;
  final VoidCallback onTap;
  final TextStyle? style;

  const ReportTapToEdit({super.key, required this.text, required this.placeholderKey, required this.onTap, this.style});

  @override
  Widget build(BuildContext context) {
    final isEmpty = text.trim().isEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ColorsManager.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsManager.borderLightGray),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                isEmpty ? appTranslation().get(placeholderKey) : text,
                style: (style ?? TextStylesManager.regular14).copyWith(
                  color: isEmpty ? ColorsManager.secondaryText : ColorsManager.mainText,
                ),
              ),
            ),
            Icon(Icons.edit_outlined, size: 16, color: ColorsManager.secondaryText),
          ],
        ),
      ),
    );
  }
}

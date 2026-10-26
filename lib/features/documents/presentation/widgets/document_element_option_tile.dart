import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/documents/presentation/document_element_label.dart';

/// One choice in [DocumentElementSheet]: «العنصر 4: …» or a plain title.
class DocumentElementOptionTile extends StatelessWidget {
  final String title;
  final int? number;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const DocumentElementOptionTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
    this.number,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? ColorsManager.primaryColor : ColorsManager.mainText;
    return ListTile(
      enabled: enabled,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: isSelected ? ColorsManager.primaryColor.withValues(alpha: 0.08) : null,
      leading: Icon(
        isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
        color: isSelected ? ColorsManager.primaryColor : ColorsManager.secondaryText,
      ),
      title: Text(
        elementLabel(title, number),
        style: TextStylesManager.medium14.copyWith(color: color),
      ),
    );
  }
}

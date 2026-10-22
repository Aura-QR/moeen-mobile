import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/documents/presentation/widgets/document_theme_swatch.dart';

/// «التصميم»: the document's accent colour.
class DocumentThemePicker extends StatelessWidget {
  final DocumentTheme selected;
  final ValueChanged<DocumentTheme> onChanged;

  const DocumentThemePicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.palette_outlined,
      title: appTranslation().get('document_section_theme'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final theme in DocumentTheme.values)
            DocumentThemeSwatch(
              theme: theme,
              isSelected: theme == selected,
              onTap: () => onChanged(theme),
            ),
        ],
      ),
    );
  }
}

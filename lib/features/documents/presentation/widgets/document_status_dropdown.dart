import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/documents/presentation/widgets/document_status_badge.dart';

/// «حالة المستند»: مسودة or نهائي, saved with the document.
class DocumentStatusDropdown extends StatelessWidget {
  final String status;
  final ValueChanged<String> onChanged;

  const DocumentStatusDropdown({super.key, required this.status, required this.onChanged});

  static const _statuses = [DocumentStatus.draft, DocumentStatus.finalized];

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.flag_outlined,
      title: appTranslation().get('document_status'),
      child: DropdownButtonFormField<String>(
        initialValue: _statuses.contains(status) ? status : DocumentStatus.draft,
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        borderRadius: BorderRadius.circular(16),
        dropdownColor: ColorsManager.surfacePrimary,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: ColorsManager.secondaryText),
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorsManager.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          helperText: appTranslation().get('document_status_note'),
          helperStyle: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: ColorsManager.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: ColorsManager.borderColor),
          ),
        ),
        items: [
          for (final value in _statuses)
            DropdownMenuItem(
              value: value,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: DocumentStatusBadge(isFinal: value == DocumentStatus.finalized),
              ),
            ),
        ],
      ),
    );
  }
}

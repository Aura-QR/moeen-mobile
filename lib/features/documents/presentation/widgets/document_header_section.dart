import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/presentation/widgets/document_header_fields.dart';
import 'package:moean/features/documents/presentation/widgets/document_header_value_row.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';

/// «الترويسة»: the defaults, read-only, with per-document overrides.
class DocumentHeaderSection extends StatelessWidget {
  final DocumentDefaultsModel defaults;
  final bool isOverriding;
  final Map<DocumentHeaderField, TextEditingController> overrideControllers;
  final ValueChanged<bool> onOverrideChanged;
  final VoidCallback onEditDefaults;

  const DocumentHeaderSection({
    super.key,
    required this.defaults,
    required this.isOverriding,
    required this.overrideControllers,
    required this.onOverrideChanged,
    required this.onEditDefaults,
  });

  static const _shownFields = [
    DocumentHeaderField.schoolName,
    DocumentHeaderField.principalName,
    DocumentHeaderField.educationDepartment,
    DocumentHeaderField.educationOffice,
  ];

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.account_balance_outlined,
      title: appTranslation().get('document_section_header'),
      trailing: TextButton(
        onPressed: onEditDefaults,
        child: Text(appTranslation().get('document_edit_defaults'), style: TextStylesManager.medium13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isOverriding)
            for (final field in _shownFields)
              DocumentHeaderValueRow(
                label: appTranslation().get(field.labelKey),
                value: defaults.text(field),
              ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: isOverriding,
            onChanged: onOverrideChanged,
            activeTrackColor: ColorsManager.primaryColor,
            title: Text(
              appTranslation().get('document_override_header'),
              style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
            ),
            subtitle: Text(
              appTranslation().get('document_override_header_note'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ),
          if (isOverriding) ...[
            verticalSpace8,
            DocumentHeaderFields(controllers: overrideControllers),
          ],
        ],
      ),
    );
  }
}

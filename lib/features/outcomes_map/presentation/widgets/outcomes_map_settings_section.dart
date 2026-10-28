import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/document_status_dropdown.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_element_section.dart';

/// Settings: layout («جدول» / «شجرة»), signatures, status, and portfolio element.
class OutcomesMapSettingsSection extends StatelessWidget {
  const OutcomesMapSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = OutcomesMapEditorCubit.get(context);
    return BlocBuilder<OutcomesMapEditorCubit, OutcomesMapEditorState>(
      buildWhen: (previous, current) =>
          previous.input.layout != current.input.layout ||
          previous.input.signatures != current.input.signatures ||
          previous.documentStatus != current.documentStatus ||
          previous.documentId != current.documentId,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimarySectionCard(
              icon: Icons.tune_rounded,
              title: appTranslation().get('outcomes_map_settings_title'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    appTranslation().get('outcomes_map_layout_label'),
                    style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
                  ),
                  verticalSpace8,
                  PrimaryChoiceChips<OutcomesMapLayout>(
                    options: OutcomesMapLayout.values,
                    labelOf: (option) => appTranslation().get(option.labelKey),
                    isSelected: (option) => option == state.input.layout,
                    onTap: cubit.setLayout,
                  ),
                  if (state.input.layout == OutcomesMapLayout.tree) ...[
                    verticalSpace6,
                    Text(
                      appTranslation().get('outcomes_map_tree_hint'),
                      style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                    ),
                  ],
                  verticalSpace12,
                  Text(
                    appTranslation().get('outcomes_map_signatures_label'),
                    style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
                  ),
                  for (final signature in OutcomesMapSignature.values)
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: state.input.signatures.contains(signature),
                      activeThumbColor: ColorsManager.primaryColor,
                      title: Text(
                        appTranslation().get(signature.labelKey),
                        style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                      ),
                      onChanged: (enabled) => cubit.toggleSignature(signature, enabled),
                    ),
                  if (state.documentId != null) ...[
                    verticalSpace10,
                    const OutcomesMapElementSection(),
                  ],
                ],
              ),
            ),
            verticalSpace14,
            DocumentStatusDropdown(
              status: state.documentStatus,
              onChanged: cubit.setDocumentStatus,
            ),
          ],
        );
      },
    );
  }
}

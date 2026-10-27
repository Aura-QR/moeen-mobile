import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_map_editor_cubit.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_element_section.dart';
import 'package:moean/features/documents/presentation/widgets/document_status_dropdown.dart';
import 'package:moean/features/documents/presentation/widgets/document_theme_picker.dart';

/// Settings section: layout («شجري» / «دائري»), answer page (`show_answers`), theme, status, and portfolio element.
class ConceptMapSettingsSection extends StatelessWidget {
  const ConceptMapSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ConceptMapEditorCubit.get(context);
    return BlocBuilder<ConceptMapEditorCubit, ConceptMapEditorState>(
      buildWhen: (previous, current) =>
          previous.input.layout != current.input.layout ||
          previous.input.showAnswers != current.input.showAnswers ||
          previous.input.hasBlanks != current.input.hasBlanks ||
          previous.input.theme != current.input.theme ||
          previous.documentStatus != current.documentStatus ||
          previous.documentId != current.documentId,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimarySectionCard(
              icon: Icons.tune_rounded,
              title: appTranslation().get('concept_map_settings_title'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    appTranslation().get('concept_map_layout_label'),
                    style: TextStylesManager.medium13.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                  verticalSpace8,
                  PrimaryChoiceChips<ConceptMapLayout>(
                    options: ConceptMapLayout.values,
                    labelOf: (option) => appTranslation().get(option.labelKey),
                    isSelected: (option) => option == state.input.layout,
                    onTap: cubit.setLayout,
                  ),
                  if (state.input.hasBlanks) ...[
                    verticalSpace10,
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: state.input.showAnswers,
                      activeThumbColor: ColorsManager.primaryColor,
                      title: Text(
                        appTranslation().get('concept_map_show_answers'),
                        style: TextStylesManager.medium14.copyWith(
                          color: ColorsManager.mainText,
                        ),
                      ),
                      subtitle: Text(
                        appTranslation().get('concept_map_show_answers_hint'),
                        style: TextStylesManager.regular12.copyWith(
                          color: ColorsManager.secondaryText,
                        ),
                      ),
                      onChanged: cubit.setShowAnswers,
                    ),
                  ],
                  if (state.documentId != null) ...[
                    verticalSpace10,
                    const ConceptMapElementSection(),
                  ],
                ],
              ),
            ),
            verticalSpace14,
            DocumentThemePicker(
              selected: state.input.theme,
              onChanged: cubit.setTheme,
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

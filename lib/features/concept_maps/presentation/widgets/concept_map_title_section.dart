import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_map_editor_cubit.dart';

/// Title field for the concept map editor.
class ConceptMapTitleSection extends StatelessWidget {
  const ConceptMapTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ConceptMapEditorCubit.get(context);
    return BlocBuilder<ConceptMapEditorCubit, ConceptMapEditorState>(
      buildWhen: (previous, current) =>
          previous.titleError != current.titleError,
      builder: (context, state) {
        final error = state.titleError;
        return PrimarySectionCard(
          icon: Icons.title_rounded,
          title: appTranslation().get('concept_map_title_label'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryTextField(
                controller: cubit.titleController,
                hint: appTranslation().get('concept_map_title_hint'),
                maxLength: ConceptMapLimits.maxTitleLength,
                onChanged: (_) => cubit.markTitleEdited(),
              ),
              if (error != null) ...[
                verticalSpace6,
                Text(
                  appTranslation().get(error),
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.errorColor,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';

/// Title field for the outcomes map editor.
class OutcomesMapTitleSection extends StatelessWidget {
  const OutcomesMapTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = OutcomesMapEditorCubit.get(context);
    return BlocBuilder<OutcomesMapEditorCubit, OutcomesMapEditorState>(
      buildWhen: (previous, current) => previous.titleError != current.titleError,
      builder: (context, state) {
        final error = state.titleError;
        return PrimarySectionCard(
          icon: Icons.title_rounded,
          title: appTranslation().get('outcomes_map_title_label'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryTextField(
                controller: cubit.titleController,
                hint: appTranslation().get('outcomes_map_title_hint'),
                maxLength: OutcomesMapLimits.maxTitleLength,
                onChanged: (_) => cubit.markTitleEdited(),
              ),
              if (error != null) ...[
                verticalSpace6,
                Text(
                  appTranslation().get(error),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

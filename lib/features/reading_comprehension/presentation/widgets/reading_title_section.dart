import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reading_comprehension/data/models/reading_models.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/reading_editor_cubit.dart';

/// Title field for the reading worksheet editor.
class ReadingTitleSection extends StatelessWidget {
  const ReadingTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReadingEditorCubit.get(context);
    return BlocBuilder<ReadingEditorCubit, ReadingEditorState>(
      buildWhen: (p, c) => p.titleError != c.titleError,
      builder: (context, state) {
        final error = state.titleError;
        return PrimarySectionCard(
          icon: Icons.title_rounded,
          title: appTranslation().get('reading_title_label'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryTextField(
                controller: cubit.titleController,
                hint: appTranslation().get('reading_title_hint'),
                maxLength: ReadingLimits.maxTitleLength,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/learning_styles/presentation/cubit/learning_style_survey_cubit.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_link_card.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_styles_note.dart';

/// «المشاركة»: a link and QR for each class.
class LearningStyleShareTab extends StatelessWidget {
  const LearningStyleShareTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LearningStyleSurveyCubit, LearningStyleSurveyState>(
      buildWhen: (a, b) => a.survey != b.survey,
      builder: (context, state) {
        final survey = state.survey;
        if (survey == null) return const SizedBox.shrink();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const LearningStylesNote(),
            verticalSpace16,
            for (final group in survey.groups) ...[
              LearningStyleLinkCard(surveyTitle: survey.title, group: group),
              verticalSpace12,
            ],
          ],
        );
      },
    );
  }
}

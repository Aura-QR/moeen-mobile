import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_state_badge.dart';

/// A survey row in «استباناتي».
class LearningStyleCard extends StatelessWidget {
  final LearningStyleSurvey survey;
  final VoidCallback onReturn;

  const LearningStyleCard({super.key, required this.survey, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.surfacePrimary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.pushNamed(context, Routes.learningStyle, arguments: survey.id);
          onReturn();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(survey.title, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                    verticalSpace4,
                    Text(
                      '${survey.groups.length} ${appTranslation().get('learning_styles_classes')}'
                      ' · ${survey.responses} ${appTranslation().get('learning_styles_responses')}',
                      style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                    ),
                  ],
                ),
              ),
              LearningStyleStateBadge(
                state: survey.isOpen ? SurveyGroupState.open : SurveyGroupState.closed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

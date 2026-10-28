import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';

/// A small coloured badge for a survey group's state (open/closed/ended).
class LearningStyleStateBadge extends StatelessWidget {
  final String state;

  const LearningStyleStateBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = state == SurveyGroupState.open ? ColorsManager.successColor : ColorsManager.secondaryText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        appTranslation().get('learning_styles_state_$state'),
        style: TextStylesManager.bold12.copyWith(color: color),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/search/data/models/search_result_model.dart';

class SearchResultItemWidget extends StatelessWidget {
  final SearchResultModel result;

  const SearchResultItemWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _TypeBadgeWidget(type: result.type),
                const Spacer(),
                if (result.difficulty != null && result.difficulty!.isNotEmpty)
                  _DifficultyBadgeWidget(difficulty: result.difficulty!),
              ],
            ),
            verticalSpace12,
            Text(
              result.title,
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
            if (result.subtitle != null) ...[
              verticalSpace4,
              Text(
                result.subtitle!,
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.secondaryText,
                ),
              ),
            ],
            if (result.options != null && result.options!.isNotEmpty) ...[
              verticalSpace12,
              ...result.options!.map(
                (option) => _OptionWidget(
                  option: option,
                  isCorrect: result.correctAnswer != null &&
                      option.contains(result.correctAnswer!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeBadgeWidget extends StatelessWidget {
  final String type;

  const _TypeBadgeWidget({required this.type});

  String _getLabel(String type) {
    switch (type) {
      case 'questions':
        return appTranslation().get('search_filter_questions');
      case 'resources':
        return appTranslation().get('search_filter_resources');
      case 'exams':
        return appTranslation().get('search_filter_exams');
      case 'lessons':
        return appTranslation().get('search_filter_lessons');
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getLabel(type),
        style: TextStylesManager.medium10.copyWith(
          color: ColorsManager.primaryColor,
        ),
      ),
    );
  }
}

class _DifficultyBadgeWidget extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadgeWidget({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsManager.secondaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        difficulty,
        style: TextStylesManager.medium10.copyWith(
          color: ColorsManager.secondaryColor,
        ),
      ),
    );
  }
}

class _OptionWidget extends StatelessWidget {
  final String option;
  final bool isCorrect;

  const _OptionWidget({required this.option, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect
            ? ColorsManager.primaryColor.withValues(alpha: 0.08)
            : ColorsManager.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect
              ? ColorsManager.primaryColor.withValues(alpha: 0.4)
              : ColorsManager.borderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option,
              style: TextStylesManager.regular13.copyWith(
                color: isCorrect
                    ? ColorsManager.primaryColor
                    : ColorsManager.textPrimary,
              ),
            ),
          ),
          if (isCorrect)
            Text(
              '(${appTranslation().get('search_correct_answer')})',
              style: TextStylesManager.bold10.copyWith(
                color: ColorsManager.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}

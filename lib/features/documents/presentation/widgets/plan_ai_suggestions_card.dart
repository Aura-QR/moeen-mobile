import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/ai_suggestions_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';

/// «اقترح من الدرس»: shown only when lessons are picked. The suggestions
/// join the sections unticked (see PlanFormScaffold).
class PlanAiSuggestionsCard extends StatelessWidget {
  const PlanAiSuggestionsCard({super.key});

  void _suggest(BuildContext context) =>
      AiSuggestionsCubit.get(context).suggest(PlanFormCubit.get(context).state.aiLessonIds);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PlanFormCubit, PlanFormState, bool>(
      selector: (state) => state.aiLessonIds.isNotEmpty,
      builder: (context, hasLessons) {
        if (!hasLessons) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.secondaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: ColorsManager.secondaryColor.withValues(alpha: 0.35)),
            ),
            child: BlocBuilder<AiSuggestionsCubit, AiSuggestionsState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status || previous.errorMessage != current.errorMessage,
              builder:(context, ai) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: ColorsManager.secondaryColor),
                      horizontalSpace10,
                      Expanded(
                        child: Text(
                          appTranslation().get('plan_ai_title'),
                          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                        ),
                      ),
                    ],
                  ),
                  verticalSpace6,
                  Text(
                    appTranslation().get(switch (ai.status) {
                      AiSuggestionsStatus.loading => 'plan_ai_loading',
                      AiSuggestionsStatus.done => 'plan_ai_done',
                      _ => 'plan_ai_subtitle',
                    }),
                    style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
                  ),
                  if (ai.status == AiSuggestionsStatus.failed) ...[
                    verticalSpace8,
                    Text(
                      appTranslation().get(ai.errorMessage ?? 'ai_suggestions_failed'),
                      style: TextStylesManager.medium13.copyWith(color: ColorsManager.errorColor),
                    ),
                  ],
                  verticalSpace12,
                  if (ai.isLoading)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        color: ColorsManager.secondaryColor,
                        backgroundColor: ColorsManager.secondaryColor.withValues(alpha: 0.15),
                      ),
                    )
                  else
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: ColorsManager.secondaryColor,
                          foregroundColor: ColorsManager.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => _suggest(context),
                        icon: Icon(
                          ai.status == AiSuggestionsStatus.failed ? Icons.refresh_rounded : Icons.auto_awesome_rounded,
                          size: 18,
                        ),
                        label: Text(
                          appTranslation().get(ai.status == AiSuggestionsStatus.failed ? 'retry' : 'plan_ai_suggest'),
                          style: TextStylesManager.bold13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

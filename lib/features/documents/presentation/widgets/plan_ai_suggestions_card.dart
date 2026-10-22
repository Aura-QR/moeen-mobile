import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/presentation/cubit/ai_suggestions_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_ai_suggestions_card.dart';

/// «اقترح من الدرس»: shown only when lessons are picked. The suggestions
/// join the sections unticked (see PlanFormScaffold).
class PlanAiSuggestionsCard extends StatelessWidget {
  const PlanAiSuggestionsCard({super.key});

  void _suggest(BuildContext context) =>
      AiSuggestionsCubit.get(context).suggest({'lesson_ids': PlanFormCubit.get(context).state.aiLessonIds});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PlanFormCubit, PlanFormState, bool>(
      selector: (state) => state.aiLessonIds.isNotEmpty,
      builder: (context, hasLessons) {
        if (!hasLessons) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DocumentAiSuggestionsCard(
            titleKey: 'plan_ai_title',
            subtitleKey: 'plan_ai_subtitle',
            actionKey: 'plan_ai_suggest',
            loadingKey: 'plan_ai_loading',
            doneKey: 'plan_ai_done',
            onSuggest: () => _suggest(context),
          ),
        );
      },
    );
  }
}

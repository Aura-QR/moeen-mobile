import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/ai_suggestions_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_ai_suggestions_card.dart';
import 'package:moean/features/documents/presentation/widgets/document_checklist_section.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_results_cubit.dart';

/// «التوصيات»: «اقترح توصيات» once there are numbers (the AI gets
/// statistics only), and the teacher's own lines. Only ticked lines are saved.
class GradeRecommendationsSection extends StatelessWidget {
  const GradeRecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocSelector<GradeResultsCubit, GradeResultsState, Map<String, dynamic>?>(
          selector: (state) => state.aiInput,
          builder: (context, aiInput) {
            if (aiInput == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: DocumentAiSuggestionsCard(
                titleKey: 'grades_ai_title',
                subtitleKey: 'grades_ai_subtitle',
                actionKey: 'grades_ai_suggest',
                loadingKey: 'plan_ai_loading',
                doneKey: 'plan_ai_done',
                onSuggest: () => AiSuggestionsCubit.get(context).suggest(aiInput),
              ),
            );
          },
        ),
        BlocBuilder<GradeAnalysisCubit, GradeAnalysisState>(
          buildWhen: (previous, current) => previous.recommendations != current.recommendations,
          builder: (context, state) => DocumentChecklistSection(
            section: state.recommendations,
            title: appTranslation().get('grades_section_recommendations'),
            addKey: 'grades_add_recommendation',
            onToggle: cubit.toggleRecommendation,
            onAdd: cubit.addRecommendation,
            onEdit: cubit.editRecommendation,
            onRemove: cubit.removeRecommendation,
          ),
        ),
        verticalSpace4,
      ],
    );
  }
}

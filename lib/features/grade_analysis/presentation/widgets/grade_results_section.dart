import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_results_cubit.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_results_view.dart';

/// «النتائج»: updated a moment after each change, or what the form still needs.
class GradeResultsSection extends StatelessWidget {
  const GradeResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final note = TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText);
    return PrimarySectionCard(
      icon: Icons.insights_rounded,
      title: appTranslation().get('grades_section_results'),
      child: BlocBuilder<GradeResultsCubit, GradeResultsState>(
        builder: (context, state) {
          final result = state.result;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.status == GradeResultsStatus.loading) ...[
                const LinearProgressIndicator(minHeight: 3),
                verticalSpace10,
              ],
              ConditionalBuilder(
                loadingState: state.status == GradeResultsStatus.loading && result == null,
                errorState: state.status == GradeResultsStatus.failure,
                emptyState: state.status == GradeResultsStatus.waiting,
                loadingBuilder: (_) => Text(appTranslation().get('grades_results_loading'), style: note),
                errorBuilder: (_) => Text(
                  appTranslation().get(state.errorMessage ?? 'generic_error'),
                  style: TextStylesManager.medium13.copyWith(color: ColorsManager.errorColor),
                ),
                emptyBuilder: (_) => Text(appTranslation().get(state.issue ?? 'grades_issue_total'), style: note),
                successBuilder: (_) => result == null ? const SizedBox.shrink() : GradeResultsView(result: result),
              ),
            ],
          );
        },
      ),
    );
  }
}

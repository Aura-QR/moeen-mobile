import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/presentation/cubit/learning_style_survey_cubit.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_bar_chart.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_response_tile.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_strategy_card.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_styles_note.dart';

/// «النتائج»: the class mix, the students, and the strategy cards.
class LearningStyleResultsTab extends StatefulWidget {
  const LearningStyleResultsTab({super.key});

  @override
  State<LearningStyleResultsTab> createState() => _LearningStyleResultsTabState();
}

class _LearningStyleResultsTabState extends State<LearningStyleResultsTab> {
  int? _groupId;

  List<StudentResponse> _responsesFor(LearningStylesResults results, int? groupId) {
    final list = groupId == null
        ? [for (final g in results.groups) ...g.responses]
        : [...results.groups.where((g) => g.id == groupId).expand((g) => g.responses)];
    list.sort((a, b) => a.studentName.compareTo(b.studentName));
    return list;
  }

  Future<bool> _confirmDelete(BuildContext context) => showPrimaryConfirmDialog(
        context,
        titleKey: 'learning_styles_delete_response_title',
        messageKey: 'learning_styles_delete_response_message',
      );

  @override
  Widget build(BuildContext context) {
    final cubit = LearningStyleSurveyCubit.get(context);
    return BlocBuilder<LearningStyleSurveyCubit, LearningStyleSurveyState>(
      buildWhen: (a, b) => a.results != b.results || a.isBusy != b.isBusy,
      builder: (context, state) {
        final results = state.results;
        if (results == null) return const Center(child: CircularProgressIndicator());
        final selected = results.groups.where((g) => g.id == _groupId).firstOrNull;
        final summary = selected?.summary ?? results.overall;
        final responses = _responsesFor(results, _groupId);
        return RefreshIndicator(
          onRefresh: cubit.refreshResults,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const LearningStylesNote(),
              verticalSpace12,
              PrimaryElevatedButton(
                text: appTranslation().get('learning_styles_report'),
                icon: const Icon(Icons.print_outlined, color: Colors.white),
                isLoading: state.isBusy,
                onPressed: cubit.saveReport,
              ),
              verticalSpace16,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    selected: _groupId == null,
                    label: Text('${appTranslation().get('learning_styles_all_classes')} (${results.overall.count})'),
                    onSelected: (_) => setState(() => _groupId = null),
                  ),
                  for (final g in results.groups)
                    ChoiceChip(
                      selected: g.id == _groupId,
                      label: Text('${g.name} (${g.summary.count})'),
                      onSelected: (_) => setState(() => _groupId = g.id),
                    ),
                ],
              ),
              verticalSpace16,
              if (summary.count == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(appTranslation().get('learning_styles_no_responses'),
                        style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText)),
                  ),
                )
              else ...[
                LearningStyleBarChart(summary: summary, styles: results.styles),
                verticalSpace16,
                Text(appTranslation().get('learning_styles_students'),
                    style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                verticalSpace8,
                for (final response in responses)
                  Dismissible(
                    key: ValueKey(response.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(context),
                    onDismissed: (_) => cubit.deleteResponse(response.id),
                    background: Container(
                      alignment: AlignmentDirectional.centerEnd,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: ColorsManager.errorColor, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    child: LearningStyleResponseTile(response: response),
                  ),
                if (summary.strategies.isNotEmpty) ...[
                  verticalSpace16,
                  Text(appTranslation().get('learning_styles_strategies'),
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                  verticalSpace8,
                  for (final strategy in summary.strategies) LearningStyleStrategyCard(strategy: strategy),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

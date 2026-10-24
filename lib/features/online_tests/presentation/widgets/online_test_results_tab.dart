import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/presentation/cubit/online_test_cubit.dart';
import 'package:moean/features/online_tests/presentation/widgets/online_test_state_badge.dart';

class OnlineTestResultsTab extends StatefulWidget {
  const OnlineTestResultsTab({super.key});

  @override
  State<OnlineTestResultsTab> createState() => _OnlineTestResultsTabState();
}

class _OnlineTestResultsTabState extends State<OnlineTestResultsTab> {
  int? _groupId;

  Future<void> _toAnalysis(BuildContext context, OnlineTestScreenState state) async {
    final cubit = OnlineTestCubit.get(context);
    final waiting = state.results?.toReview ?? 0;
    if (waiting > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text(appTranslation().get('online_tests_analysis_warning').replaceAll('{n}', '$waiting')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(appTranslation().get('cancel'))),
            TextButton(onPressed: () => Navigator.pop(c, true), child: Text(appTranslation().get('online_tests_continue'))),
          ],
        ),
      );
      if (ok != true) return;
    }
    await cubit.toAnalysis();
  }

  Future<void> _accept(BuildContext context, int count) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(appTranslation().get('online_tests_ai_accept_confirm').replaceAll('{n}', '$count')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(appTranslation().get('cancel'))),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(appTranslation().get('online_tests_ai_accept'))),
        ],
      ),
    );
    if (ok == true && context.mounted) await OnlineTestCubit.get(context).acceptSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = OnlineTestCubit.get(context);
    final state = context.watch<OnlineTestCubit>().state;
    final results = state.results;
    final test = state.test!;
    if (results == null) return const Center(child: CircularProgressIndicator());
    final group = results.groups.where((g) => g.id == _groupId).firstOrNull ?? results.groups.firstOrNull;
    final questions = [...results.questions]..sort((a, b) => (a.correctRate ?? 101).compareTo(b.correctRate ?? 101));

    return RefreshIndicator(
      onRefresh: cubit.refreshResults,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PrimaryElevatedButton(
            text: appTranslation().get('online_tests_to_analysis'),
            isLoading: state.isBusy,
            onPressed: () => _toAnalysis(context, state),
          ),
          if (results.toReview > 0) ...[
            verticalSpace8,
            Text(appTranslation().get('online_tests_to_review').replaceAll('{n}', '${results.toReview}'),
                style: TextStylesManager.bold13.copyWith(color: ColorsManager.statusWarning)),
          ],
          if (results.aiWaiting > 0 || results.aiSuggested > 0 || state.aiRunning) ...[
            verticalSpace12,
            _AiBox(
              waiting: results.aiWaiting,
              suggested: results.aiSuggested,
              running: state.aiRunning,
              done: state.aiDone,
              onSuggest: cubit.suggestMarks,
              onAccept: () => _accept(context, results.aiSuggested),
            ),
          ],
          verticalSpace16,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in results.groups)
                ChoiceChip(
                  selected: g.id == group?.id,
                  label: Text('${g.name} (${g.submissions.length}${g.average != null ? ' · ${appTranslation().get('online_tests_average')} ${formatPoints(g.average)}' : ''})'),
                  onSelected: (_) => setState(() => _groupId = g.id),
                ),
            ],
          ),
          verticalSpace8,
          if (group == null || group.submissions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text(appTranslation().get('online_tests_no_submissions_class'), style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText))),
            )
          else
            for (final s in group.submissions)
              Card(
                color: ColorsManager.surfacePrimary,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(s.studentName, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                  subtitle: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (s.fieldValues.isNotEmpty) Text(s.fieldValues.join(' · '), style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
                      if (s.needsReview) OnlineTestTag(text: appTranslation().get('online_tests_needs_review'), color: ColorsManager.statusWarning),
                      if (s.aiSuggested > 0) OnlineTestTag(text: appTranslation().get('online_tests_ai_tag'), color: ColorsManager.statusActivity),
                      if (s.late) OnlineTestTag(text: appTranslation().get('online_tests_late'), color: ColorsManager.errorColor),
                    ],
                  ),
                  trailing: Text('${formatPoints(s.score)} / ${formatPoints(test.totalPoints)}', style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                  onTap: () async {
                    final queue = results.groups.expand((g) => g.submissions).where((x) => x.needsReview && x.id != s.id).map((x) => x.id).toList();
                    await Navigator.pushNamed(context, Routes.onlineTestReview, arguments: {'test_id': test.id, 'submission_id': s.id, 'next': queue});
                    await cubit.refreshResults();
                  },
                ),
              ),
          verticalSpace16,
          Text(appTranslation().get('online_tests_hardest'), style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
          verticalSpace8,
          for (final q in questions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText)),
                  verticalSpace4,
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (q.correctRate ?? 0) / 100,
                            minHeight: 8,
                            backgroundColor: ColorsManager.borderLightGray,
                            color: ColorsManager.primaryColor,
                          ),
                        ),
                      ),
                      horizontalSpace8,
                      Text(
                        q.correctRate == null
                            ? appTranslation().get('online_tests_no_answers')
                            : '${formatPoints(q.correctRate)}%${q.toReview > 0 ? ' · ${appTranslation().get('online_tests_waiting')} ${q.toReview}' : ''}',
                        style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// «تصحيح مقترح بالذكاء الاصطناعي».
class _AiBox extends StatelessWidget {
  final int waiting;
  final int suggested;
  final bool running;
  final int done;
  final VoidCallback onSuggest;
  final VoidCallback onAccept;

  const _AiBox({required this.waiting, required this.suggested, required this.running, required this.done, required this.onSuggest, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    const violet = ColorsManager.statusActivity;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: violet.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: violet.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✨ ${appTranslation().get('online_tests_ai_title')}', style: TextStylesManager.bold14.copyWith(color: violet)),
          verticalSpace4,
          Text(appTranslation().get('online_tests_ai_hint'), style: TextStylesManager.regular12.copyWith(color: ColorsManager.mainText)),
          verticalSpace8,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (waiting > 0 || running)
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: violet),
                  onPressed: running ? null : onSuggest,
                  child: Text(running
                      ? '${appTranslation().get('online_tests_ai_running')}${done > 0 ? ' ($done)' : ''}'
                      : appTranslation().get('online_tests_ai_suggest').replaceAll('{n}', '$waiting')),
                ),
              if (suggested > 0 && !running)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: violet, side: const BorderSide(color: violet)),
                  onPressed: onAccept,
                  child: Text('${appTranslation().get('online_tests_ai_accept')} ($suggested)'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

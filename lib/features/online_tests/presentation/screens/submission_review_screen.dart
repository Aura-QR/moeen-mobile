import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/data/repositories/online_tests_repository.dart';
import 'package:moean/features/online_tests/presentation/cubit/submission_review_cubit.dart';

/// One student's answers, with a mark field per question. «التالي» opens the next one waiting for review.
class SubmissionReviewScreen extends StatelessWidget {
  final List<int> next;

  const SubmissionReviewScreen({super.key, this.next = const []});

  /// [args]: `{'test_id': int, 'submission_id': int, 'next': List<int>}`.
  static Widget create(Map<String, dynamic> args) => BlocProvider(
        create: (_) => SubmissionReviewCubit(
          testId: args['test_id'] as int,
          submissionId: args['submission_id'] as int,
          repository: OnlineTestsRepository(),
        )..load(),
        child: SubmissionReviewScreen(next: (args['next'] as List?)?.whereType<int>().toList() ?? const []),
      );

  void _openNext(BuildContext context) {
    if (next.isEmpty) return;
    Navigator.pushReplacementNamed(context, Routes.onlineTestReview, arguments: {
      'test_id': SubmissionReviewCubit.get(context).testId,
      'submission_id': next.first,
      'next': next.sublist(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = SubmissionReviewCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: BlocBuilder<SubmissionReviewCubit, SubmissionReviewState>(
          builder: (_, s) => Text(s.detail?.row.studentName ?? '', style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: ColorsManager.errorColor),
            tooltip: appTranslation().get('online_tests_delete_submission'),
            onPressed: () async {
              final ok = await showPrimaryConfirmDialog(context, titleKey: 'online_tests_delete_submission', messageKey: 'online_tests_delete_submission_message');
              if (ok) await cubit.delete();
            },
          ),
        ],
      ),
      body: BlocConsumer<SubmissionReviewCubit, SubmissionReviewState>(
        listenWhen: (a, b) => a.error != b.error || a.saved != b.saved || a.deleted != b.deleted,
        listener: (context, state) {
          if (state.deleted) {
            Navigator.pop(context);
          } else if (state.error != null && state.detail != null) {
            showPrimarySnackBar(context, appTranslation().get(state.error!), isError: true);
            cubit.clearError();
          } else if (state.saved) {
            showPrimarySnackBar(context, appTranslation().get('online_tests_saved'), isError: false);
          }
        },
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          final detail = state.detail;
          if (detail == null) return PrimaryErrorView(message: state.error ?? 'generic_error', onRetry: cubit.load);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${appTranslation().get('online_tests_score')}: ${formatPoints(detail.row.score)}',
                  style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
              if (detail.row.fieldValues.isNotEmpty)
                Text(detail.row.fieldValues.join(' · '), style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
              verticalSpace12,
              for (var i = 0; i < detail.answers.length; i++) ...[
                _AnswerCard(index: i, answer: detail.answers[i], value: state.marks[detail.answers[i].questionId] ?? '', onChanged: (v) => cubit.setMark(detail.answers[i].questionId, v)),
                verticalSpace12,
              ],
              PrimaryElevatedButton(text: appTranslation().get('online_tests_save_marks'), isLoading: state.isSaving, onPressed: cubit.save),
              if (next.isNotEmpty) ...[
                verticalSpace8,
                OutlinedButton(onPressed: () => _openNext(context), child: Text('${appTranslation().get('online_tests_next_review')} (${next.length})')),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AnswerCard extends StatefulWidget {
  final int index;
  final SubmissionAnswer answer;
  final String value;
  final ValueChanged<String> onChanged;

  const _AnswerCard({required this.index, required this.answer, required this.value, required this.onChanged});

  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _AnswerCard old) {
    super.didUpdateWidget(old);
    // After a save the server's marks replace what was typed.
    if (widget.value != _controller.text && widget.value != old.value) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.answer;
    final waiting = a.mark == null;
    const violet = ColorsManager.statusActivity;
    final answerText = a.answerText;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: waiting ? ColorsManager.statusWarning : ColorsManager.borderLightGray, width: waiting ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.index + 1}. ${appTranslation().get('online_tests_type_${a.type}')} · ${formatPoints(a.points)} ${appTranslation().get('online_tests_points')}',
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
          verticalSpace4,
          Text(a.text, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
          verticalSpace8,
          Text('${appTranslation().get('online_tests_student_answer')}: ${answerText.isEmpty ? appTranslation().get('online_tests_no_answer') : answerText}',
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText)),
          verticalSpace4,
          Text('${appTranslation().get('online_tests_right_answer')}: ${a.correctAnswer}', style: TextStylesManager.regular13.copyWith(color: ColorsManager.successColor)),
          if (waiting && a.aiMark != null) ...[
            verticalSpace8,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: violet.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✨ ${appTranslation().get('online_tests_ai_mark')}: ${formatPoints(a.aiMark)} / ${formatPoints(a.points)}', style: TextStylesManager.bold13.copyWith(color: violet)),
                  if (a.aiReason.isNotEmpty) Text(a.aiReason, style: TextStylesManager.regular12.copyWith(color: ColorsManager.mainText)),
                  Text(appTranslation().get('online_tests_ai_mark_hint'), style: TextStylesManager.regular10.copyWith(color: ColorsManager.secondaryText)),
                ],
              ),
            ),
          ],
          verticalSpace8,
          Row(
            children: [
              Text(appTranslation().get('online_tests_mark'), style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText)),
              horizontalSpace8,
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                  decoration: InputDecoration(isDense: true, hintText: appTranslation().get('online_tests_waiting'), border: const OutlineInputBorder()),
                  onChanged: widget.onChanged,
                ),
              ),
              horizontalSpace8,
              Text('/ ${formatPoints(a.points)}', style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText)),
            ],
          ),
        ],
      ),
    );
  }
}

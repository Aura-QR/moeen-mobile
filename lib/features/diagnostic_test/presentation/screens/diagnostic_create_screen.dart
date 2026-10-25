import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/diagnostic_test/data/repositories/diagnostic_repository.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_cubit.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/diagnostic_question_card.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/subject_picker_sheet.dart';

/// «الاختبار التشخيصي»: subject → the AI writes questions per prior skill → review → save.
class DiagnosticCreateScreen extends StatefulWidget {
  const DiagnosticCreateScreen({super.key});

  static Widget create() => BlocProvider(create: (_) => DiagnosticCreateCubit(DiagnosticRepository()), child: const DiagnosticCreateScreen());

  @override
  State<DiagnosticCreateScreen> createState() => _DiagnosticCreateScreenState();
}

class _DiagnosticCreateScreenState extends State<DiagnosticCreateScreen> {
  final TextEditingController _notes = TextEditingController();
  TextEditingController? _title;

  @override
  void dispose() {
    _notes.dispose();
    _title?.dispose();
    super.dispose();
  }

  Widget _card(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: ColorsManager.surfacePrimary, borderRadius: BorderRadius.circular(16), border: Border.all(color: ColorsManager.borderLightGray)),
        child: child,
      );

  Widget _count(String key, int value, List<int> values, ValueChanged<int> onChanged) => Row(
        children: [
          Expanded(child: Text(appTranslation().get(key), style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText))),
          DropdownButton<int>(
            value: value,
            items: [for (final v in values) DropdownMenuItem(value: v, child: Text('$v'))],
            onChanged: (v) => v == null ? null : onChanged(v),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final cubit = DiagnosticCreateCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(appTranslation().get('diagnostic_title'), style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
      ),
      body: BlocConsumer<DiagnosticCreateCubit, DiagnosticCreateState>(
        listenWhen: (a, b) => a.error != b.error || a.savedExamId != b.savedExamId,
        listener: (context, state) {
          if (state.error != null) {
            showPrimarySnackBar(context, appTranslation().get(state.error!), isError: true);
            cubit.clearError();
          }
          if (state.savedExamId != null) {
            showPrimarySnackBar(context, appTranslation().get('diagnostic_saved'), isError: false);
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          if (state.step == DiagnosticStep.review) {
            _title ??= TextEditingController(text: state.title);
            return _review(context, state);
          }
          // A new round starts with a fresh title.
          _title?.dispose();
          _title = null;
          return _pick(context, state);
        },
      ),
    );
  }

  Widget _pick(BuildContext context, DiagnosticCreateState state) {
    final cubit = DiagnosticCreateCubit.get(context);
    final source = state.source;
    final writing = state.step == DiagnosticStep.writing;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(appTranslation().get('diagnostic_intro'), style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText)),
        verticalSpace12,
        _card(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(appTranslation().get('diagnostic_step_subject'), style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
            verticalSpace8,
            OutlinedButton.icon(
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(state.subjectId == null ? appTranslation().get('diagnostic_pick_subject') : state.subjectLabel),
              onPressed: writing
                  ? null
                  : () async {
                      final picked = await showSubjectPickerSheet(context);
                      if (picked != null) cubit.pickSubject(picked.subjectId, '${picked.subjectName} — ${picked.gradeName}');
                    },
            ),
            if (source != null) ...[
              verticalSpace8,
              Text(
                source.isReadiness
                    ? appTranslation().get('diagnostic_source_readiness')
                    : appTranslation().get('diagnostic_source_previous').replaceAll('{subject}', source.subject).replaceAll('{grade}', source.sourceGrade ?? ''),
                style: TextStylesManager.medium13.copyWith(color: ColorsManager.primaryColor),
              ),
              if (source.lessonsCount == 0)
                Text(appTranslation().get('diagnostic_no_lessons'), style: TextStylesManager.bold12.copyWith(color: ColorsManager.errorColor)),
            ],
          ],
        )),
        _card(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(appTranslation().get('diagnostic_step_size'), style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
            _count('diagnostic_skills_count', state.skillsCount, const [2, 3, 4, 5, 6, 7, 8], cubit.setSkillsCount),
            _count('diagnostic_per_skill', state.perSkill, const [1, 2, 3, 4, 5], cubit.setPerSkill),
            TextField(
              controller: _notes,
              maxLength: 500,
              style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
              decoration: InputDecoration(labelText: appTranslation().get('diagnostic_notes'), isDense: true, border: const OutlineInputBorder()),
            ),
            Text(
              appTranslation().get('diagnostic_size_hint').replaceAll('{n}', '${state.skillsCount * state.perSkill}'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
        )),
        PrimaryElevatedButton(
          text: appTranslation().get(writing ? 'diagnostic_writing' : 'diagnostic_generate'),
          isLoading: writing,
          onPressed: state.subjectId == null || source?.lessonsCount == 0 ? null : () => cubit.generate(notes: _notes.text),
        ),
      ],
    );
  }

  Widget _review(BuildContext context, DiagnosticCreateState state) {
    final cubit = DiagnosticCreateCubit.get(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _card(Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              maxLength: 255,
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
              decoration: InputDecoration(labelText: appTranslation().get('online_tests_test_title'), isDense: true, border: const OutlineInputBorder()),
              onChanged: cubit.setTitle,
            ),
            Text(
              appTranslation().get('diagnostic_review_hint').replaceAll('{skills}', '${state.skills.length}').replaceAll('{n}', '${state.questionsCount}'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
          ],
        )),
        for (var si = 0; si < state.skills.length; si++)
          _card(Column(
            key: ValueKey('skill-$si-${state.skills.length}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: state.skills[si].name,
                      maxLength: 120,
                      style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                      decoration: InputDecoration(labelText: '${appTranslation().get('diagnostic_skill')} ${si + 1}', isDense: true, border: const OutlineInputBorder()),
                      onChanged: (v) => cubit.renameSkill(si, v),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.delete_outline, color: ColorsManager.errorColor), tooltip: appTranslation().get('diagnostic_remove_skill'), onPressed: () => cubit.removeSkill(si)),
                ],
              ),
              for (var qi = 0; qi < state.skills[si].questions.length; qi++) ...[
                DiagnosticQuestionCard(
                  key: ValueKey('q-$si-$qi-${state.skills[si].questions.length}'),
                  index: qi,
                  question: state.skills[si].questions[qi],
                  onChanged: (q) => cubit.updateQuestion(si, qi, q),
                  onRemove: () => cubit.removeQuestion(si, qi),
                ),
                verticalSpace8,
              ],
              TextButton.icon(icon: const Icon(Icons.add), label: Text(appTranslation().get('diagnostic_add_question')), onPressed: () => cubit.addQuestion(si)),
            ],
          )),
        PrimaryElevatedButton(text: appTranslation().get('diagnostic_save'), isLoading: state.isSaving, onPressed: cubit.save),
        verticalSpace8,
        OutlinedButton(onPressed: cubit.restart, child: Text(appTranslation().get('diagnostic_restart'))),
        verticalSpace8,
        Text(appTranslation().get('diagnostic_after_save'), style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
      ],
    );
  }
}

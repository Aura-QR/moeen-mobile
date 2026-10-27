import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';
import 'package:moean/features/diagnostic_test/data/repositories/diagnostic_repository.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnosis_cubit.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';

/// Red below the weak line, amber in between, green from the strong line.
Color masteryColor(double? value, Diagnosis d) {
  if (value == null) return ColorsManager.secondaryText;
  if (value < d.weakBelow) return ColorsManager.errorColor;
  if (value < d.strongFrom) return ColorsManager.statusWarning;
  return ColorsManager.successColor;
}

String _pct(double? v) => v == null ? '—' : '${v.round()}%';

/// «التشخيص»: mastery per skill, the students who need support, and plans in one tap.
class DiagnosisScreen extends StatelessWidget {
  final String? title;

  const DiagnosisScreen({super.key, this.title});

  static Widget create(dynamic arg) {
    final int onlineTestId;
    final String? customTitle;
    if (arg is Map) {
      onlineTestId = (arg['test_id'] as num?)?.toInt() ?? 0;
      customTitle = arg['title']?.toString();
    } else if (arg is num) {
      onlineTestId = arg.toInt();
      customTitle = null;
    } else {
      onlineTestId = int.tryParse('$arg') ?? 0;
      customTitle = null;
    }

    return BlocProvider(
      create: (_) => DiagnosisCubit(
        testId: onlineTestId,
        repository: DiagnosticRepository(),
        documents: DocumentsRepository(),
      )..load(),
      child: DiagnosisScreen(title: customTitle),
    );
  }

  Future<void> _plan(BuildContext context, DiagnosisState state, String type) async {
    final d = state.diagnosis!;
    if (d.toReview > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          content: Text(appTranslation().get('diagnostic_review_warning').replaceAll('{n}', '${d.toReview}')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text(appTranslation().get('cancel'))),
            TextButton(onPressed: () => Navigator.pop(c, true), child: Text(appTranslation().get('online_tests_continue'))),
          ],
        ),
      );
      if (ok != true) return;
    }
    if (context.mounted) await DiagnosisCubit.get(context).createPlan(type);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = DiagnosisCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(title ?? appTranslation().get('diagnostic_diagnosis'), style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
      ),
      body: BlocConsumer<DiagnosisCubit, DiagnosisState>(
        listenWhen: (a, b) => a.createdPlan != b.createdPlan || (a.error != b.error && b.diagnosis != null),
        listener: (context, state) async {
          final plan = state.createdPlan;
          if (plan != null) {
            cubit.clearPlan();
            await Navigator.pushNamed(context, plan.type == 'remedial_plan' ? Routes.remedialPlan : Routes.enrichmentPlan, arguments: plan.id);
          } else if (state.error != null) {
            showPrimarySnackBar(context, appTranslation().get(state.error!), isError: true);
            cubit.clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          final d = state.diagnosis;
          if (d == null) return PrimaryErrorView(message: state.error ?? 'generic_error', onRetry: cubit.load);
          if (d.students.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(appTranslation().get('diagnostic_no_answers'), textAlign: TextAlign.center)));
          }
          final skills = [...d.skills]..sort((a, b) => (state.masteryOf(a) ?? 101).compareTo(state.masteryOf(b) ?? 101));
          final groups = {for (final s in d.students) s.groupId: s.group};
          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (d.toReview > 0)
                  Text(appTranslation().get('diagnostic_partial').replaceAll('{n}', '${d.toReview}'), style: TextStylesManager.bold12.copyWith(color: ColorsManager.statusWarning)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: ColorsManager.errorColor),
                      onPressed: state.isBusy || d.remedialCount == 0 ? null : () => _plan(context, state, 'remedial_plan'),
                      child: Text('${appTranslation().get('diagnostic_remedial')} (${d.remedialCount})'),
                    ),
                    if (d.enrichmentCount > 0)
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: ColorsManager.successColor),
                        onPressed: state.isBusy ? null : () => _plan(context, state, 'enrichment_plan'),
                        child: Text('${appTranslation().get('diagnostic_enrichment')} (${d.enrichmentCount})'),
                      ),
                  ],
                ),
                if (groups.length > 1) ...[
                  verticalSpace8,
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(label: Text(appTranslation().get('diagnostic_all_classes')), selected: state.groupId == null, onSelected: (_) => cubit.setGroup(null)),
                      for (final g in groups.entries) ChoiceChip(label: Text(g.value), selected: state.groupId == g.key, onSelected: (_) => cubit.setGroup(g.key)),
                    ],
                  ),
                ],
                verticalSpace16,
                Text(appTranslation().get('diagnostic_skills_weakest'), style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                verticalSpace8,
                for (final s in skills) _SkillTile(skill: s, mastery: state.masteryOf(s), diagnosis: d, groupId: state.groupId),
                verticalSpace16,
                Text(appTranslation().get('diagnostic_students'), style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                verticalSpace8,
                for (final st in state.students)
                  Card(
                    color: ColorsManager.surfacePrimary,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(st.name, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                          verticalSpace4,
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final s in d.skills)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: masteryColor(st.skills[s.name], d).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                                  child: Text('${s.name}: ${_pct(st.skills[s.name])}', style: TextStylesManager.medium10.copyWith(color: masteryColor(st.skills[s.name], d))),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                Text(
                  appTranslation().get('diagnostic_legend').replaceAll('{weak}', '${d.weakBelow.round()}').replaceAll('{strong}', '${d.strongFrom.round()}'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  final SkillDiagnosis skill;
  final double? mastery;
  final Diagnosis diagnosis;
  final int? groupId;

  const _SkillTile({required this.skill, required this.mastery, required this.diagnosis, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final color = masteryColor(mastery, diagnosis);
    final inGroup = {for (final s in diagnosis.students) if (groupId == null || s.groupId == groupId) s.submissionId};
    final weak = skill.weakStudents.where((w) => inGroup.contains(w.submissionId)).toList();
    return Card(
      color: ColorsManager.surfacePrimary,
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(skill.name, style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: (mastery ?? 0) / 100, minHeight: 8, color: color, backgroundColor: ColorsManager.borderLightGray),
                ),
              ),
              horizontalSpace8,
              Text(_pct(mastery), style: TextStylesManager.bold13.copyWith(color: color)),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                weak.isEmpty
                    ? appTranslation().get('diagnostic_no_weak')
                    : '${appTranslation().get('diagnostic_need_support')}: ${weak.map((w) => '${w.name} (${_pct(w.mastery)})').join('، ')}',
                style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

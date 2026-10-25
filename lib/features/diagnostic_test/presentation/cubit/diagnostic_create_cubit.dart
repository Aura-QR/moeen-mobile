import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';
import 'package:moean/features/diagnostic_test/data/repositories/diagnostic_repository.dart';

enum DiagnosticStep { pick, writing, review }

class DiagnosticCreateState {
  final DiagnosticStep step;
  final int? subjectId;
  final String subjectLabel;
  final DiagnosticSource? source;
  final int skillsCount;
  final int perSkill;
  final List<DiagnosticSkill> skills;
  final String title;
  final bool isSaving;
  final String? error;

  /// Set once saved; the screen leaves.
  final int? savedExamId;

  const DiagnosticCreateState({
    this.step = DiagnosticStep.pick,
    this.subjectId,
    this.subjectLabel = '',
    this.source,
    this.skillsCount = 5,
    this.perSkill = 3,
    this.skills = const [],
    this.title = '',
    this.isSaving = false,
    this.error,
    this.savedExamId,
  });

  int get questionsCount => skills.fold(0, (n, s) => n + s.questions.length);
  bool get allComplete => skills.every((s) => s.name.trim().isNotEmpty && s.questions.every((q) => q.isComplete));

  DiagnosticCreateState copyWith({
    DiagnosticStep? step,
    int? subjectId,
    String? subjectLabel,
    DiagnosticSource? source,
    bool clearSource = false,
    int? skillsCount,
    int? perSkill,
    List<DiagnosticSkill>? skills,
    String? title,
    bool? isSaving,
    String? error,
    bool clearError = false,
    int? savedExamId,
  }) =>
      DiagnosticCreateState(
        step: step ?? this.step,
        subjectId: subjectId ?? this.subjectId,
        subjectLabel: subjectLabel ?? this.subjectLabel,
        source: clearSource ? null : source ?? this.source,
        skillsCount: skillsCount ?? this.skillsCount,
        perSkill: perSkill ?? this.perSkill,
        skills: skills ?? this.skills,
        title: title ?? this.title,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
        savedExamId: savedExamId ?? this.savedExamId,
      );
}

/// Subject → the AI writes skills and questions → the teacher reviews → a diagnostic exam.
class DiagnosticCreateCubit extends Cubit<DiagnosticCreateState> {
  final DiagnosticRepository _repository;
  final Duration pollEvery;

  DiagnosticCreateCubit(this._repository, {this.pollEvery = const Duration(seconds: 3)}) : super(const DiagnosticCreateState());

  static DiagnosticCreateCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> pickSubject(int id, String label) async {
    emit(state.copyWith(subjectId: id, subjectLabel: label, clearSource: true, clearError: true));
    final result = await _repository.getSource(id);
    if (isClosed || state.subjectId != id) return;
    result.fold((_) {}, (source) => emit(state.copyWith(source: source)));
  }

  void setSkillsCount(int v) => emit(state.copyWith(skillsCount: v));
  void setPerSkill(int v) => emit(state.copyWith(perSkill: v));

  Future<void> generate({String notes = ''}) async {
    final subjectId = state.subjectId;
    if (subjectId == null || state.step == DiagnosticStep.writing) return;
    emit(state.copyWith(step: DiagnosticStep.writing, clearError: true));
    final started = await _repository.start(subjectId: subjectId, skills: state.skillsCount, perSkill: state.perSkill, notes: notes);
    if (isClosed) return;
    var job = started.fold((f) {
      emit(state.copyWith(step: DiagnosticStep.pick, error: f.message));
      return null;
    }, (j) => j);
    for (var i = 0; job != null && job.isPending && i < 100; i++) {
      final current = job;
      await Future<void>.delayed(pollEvery);
      if (isClosed) return;
      final polled = await _repository.getJob(current.id);
      job = polled.fold((_) => current, (j) => j);
    }
    if (job == null) return;
    if (!job.isDone || job.skills.isEmpty) {
      emit(state.copyWith(step: DiagnosticStep.pick, error: job.error ?? 'diagnostic_failed'));
      return;
    }
    final source = state.source;
    emit(state.copyWith(
      step: DiagnosticStep.review,
      skills: job.skills,
      title: 'اختبار تشخيصي — ${source?.subject ?? state.subjectLabel}${source?.grade != null ? ' — ${source!.grade}' : ''}',
    ));
  }

  void setTitle(String v) => emit(state.copyWith(title: v));

  void renameSkill(int i, String name) => _skill(i, (s) => s.copyWith(name: name));
  void removeSkill(int i) => emit(state.copyWith(skills: [...state.skills]..removeAt(i)));

  void updateQuestion(int skill, int index, DiagnosticQuestion q) =>
      _skill(skill, (s) => s.copyWith(questions: [...s.questions]..[index] = q));
  void removeQuestion(int skill, int index) => _skill(skill, (s) => s.copyWith(questions: [...s.questions]..removeAt(index)));
  void addQuestion(int skill) =>
      _skill(skill, (s) => s.copyWith(questions: [...s.questions, const DiagnosticQuestion(type: DiagnosticQuestionTypes.mcq, text: '')]));

  void _skill(int i, DiagnosticSkill Function(DiagnosticSkill) change) {
    final skills = [...state.skills];
    skills[i] = change(skills[i]);
    emit(state.copyWith(skills: skills));
  }

  void restart() => emit(state.copyWith(step: DiagnosticStep.pick, skills: const []));

  Future<void> save() async {
    final subjectId = state.subjectId;
    final kept = state.skills.where((s) => s.name.trim().isNotEmpty && s.questions.isNotEmpty).toList();
    if (subjectId == null || state.isSaving) return;
    if (kept.isEmpty) return emit(state.copyWith(error: 'diagnostic_no_skills'));
    if (!kept.every((s) => s.questions.every((q) => q.isComplete))) return emit(state.copyWith(error: 'diagnostic_missing_answers'));
    emit(state.copyWith(isSaving: true, clearError: true));
    final result = await _repository.save(subjectId: subjectId, title: state.title.trim().isEmpty ? 'اختبار تشخيصي' : state.title.trim(), skills: kept);
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(isSaving: false, error: f.message)),
      (id) => emit(state.copyWith(isSaving: false, savedExamId: id)),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
}

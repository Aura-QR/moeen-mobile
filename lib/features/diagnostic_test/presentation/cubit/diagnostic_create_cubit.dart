import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';
import 'package:moean/features/diagnostic_test/data/repositories/diagnostic_repository.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_state.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

export 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_state.dart';

/// Stage → Grade → Subject → AI writes skills and questions → teacher reviews → diagnostic exam.
class DiagnosticCreateCubit extends Cubit<DiagnosticCreateState> {
  final DiagnosticRepository _repository;
  final Duration pollEvery;

  DiagnosticCreateCubit(this._repository, {this.pollEvery = const Duration(seconds: 3)}) : super(const DiagnosticCreateState());

  static DiagnosticCreateCubit get(BuildContext context) => BlocProvider.of(context);

  static int _stageWeight(String name) {
    if (name.contains('الابتدائية')) return 1;
    if (name.contains('المتوسطة')) return 2;
    if (name.contains('الثانوية')) return 3;
    return 4;
  }

  static List<CurriculumStageModel> _sortStages(List<CurriculumStageModel> items) =>
      [...items]..sort((a, b) => _stageWeight(a.name).compareTo(_stageWeight(b.name)));

  Future<void> loadStages() async {
    emit(state.copyWith(isStagesLoading: true, clearStagesError: true));
    final result = await _repository.getStages();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isStagesLoading: false, stagesError: failure.message)),
      (stages) => emit(state.copyWith(isStagesLoading: false, stages: _sortStages(stages))),
    );
  }

  void selectStage(CurriculumStageModel stage) {
    if (state.selectedStage?.id == stage.id) return;
    emit(state.copyWith(
      selectedStage: stage,
      clearTrack: true,
      clearGrade: true,
      clearSubject: true,
      isSourceLoading: false,
      clearSource: true,
      clearError: true,
    ));
  }

  void selectTrack(String track) {
    if (state.selectedTrack == track) return;
    emit(state.copyWith(
      selectedTrack: track,
      clearGrade: true,
      clearSubject: true,
      isSourceLoading: false,
      clearSource: true,
      clearError: true,
    ));
  }

  void selectGrade(CurriculumGradeModel grade) {
    if (state.selectedGrade?.id == grade.id) return;
    emit(state.copyWith(
      selectedGrade: grade,
      clearSubject: true,
      isSourceLoading: false,
      clearSource: true,
      clearError: true,
    ));
  }

  Future<void> selectSubject(CurriculumSubjectModel subject) {
    final gradeName = state.selectedGrade?.name ?? '';
    final label = gradeName.isNotEmpty ? '${subject.name} — $gradeName' : subject.name;
    return pickSubject(subject.id, label, subject: subject);
  }

  Future<void> pickSubject(int id, String label, {CurriculumSubjectModel? subject}) async {
    emit(state.copyWith(
      selectedSubject: subject,
      subjectId: id,
      subjectLabel: label,
      isSourceLoading: true,
      clearSource: true,
      clearError: true,
    ));
    final result = await _repository.getSource(id);
    if (isClosed || state.subjectId != id) return;
    result.fold(
      (_) => emit(state.copyWith(isSourceLoading: false)),
      (source) => emit(state.copyWith(isSourceLoading: false, source: source)),
    );
  }

  void setSkillsCount(int v) => emit(state.copyWith(skillsCount: v));
  void setPerSkill(int v) => emit(state.copyWith(perSkill: v));
  void setNotes(String v) => emit(state.copyWith(notes: v));

  Future<void> generate({String? notes}) async {
    final subjectId = state.subjectId;
    if (subjectId == null || state.step == DiagnosticStep.writing) return;
    emit(state.copyWith(step: DiagnosticStep.writing, clearError: true));
    final started = await _repository.start(
      subjectId: subjectId,
      skills: state.skillsCount,
      perSkill: state.perSkill,
      notes: notes ?? state.notes,
    );
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
    final result = await _repository.save(
      subjectId: subjectId,
      title: state.title.trim().isEmpty ? 'اختبار تشخيصي' : state.title.trim(),
      skills: kept,
    );
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(isSaving: false, error: f.message)),
      (id) => emit(state.copyWith(isSaving: false, savedExamId: id)),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
}

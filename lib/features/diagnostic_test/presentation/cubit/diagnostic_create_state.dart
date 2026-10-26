import 'package:moean/features/diagnostic_test/data/models/diagnostic_models.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

enum DiagnosticStep { pick, writing, review }

class DiagnosticCreateState {
  final DiagnosticStep step;
  final bool isStagesLoading;
  final String? stagesError;
  final List<CurriculumStageModel> stages;
  final CurriculumStageModel? selectedStage;
  final String? selectedTrack;
  final CurriculumGradeModel? selectedGrade;
  final CurriculumSubjectModel? selectedSubject;
  final int? subjectId;
  final String subjectLabel;
  final bool isSourceLoading;
  final DiagnosticSource? source;
  final int skillsCount;
  final int perSkill;
  final String notes;
  final List<DiagnosticSkill> skills;
  final String title;
  final bool isSaving;
  final String? error;

  /// Set once saved; the screen leaves.
  final int? savedExamId;

  const DiagnosticCreateState({
    this.step = DiagnosticStep.pick,
    this.isStagesLoading = false,
    this.stagesError,
    this.stages = const [],
    this.selectedStage,
    this.selectedTrack,
    this.selectedGrade,
    this.selectedSubject,
    this.subjectId,
    this.subjectLabel = '',
    this.isSourceLoading = false,
    this.source,
    this.skillsCount = 5,
    this.perSkill = 3,
    this.notes = '',
    this.skills = const [],
    this.title = '',
    this.isSaving = false,
    this.error,
    this.savedExamId,
  });

  List<String> get availableTracks {
    if (selectedStage == null) return const [];
    final tracks = <String>{};
    for (final g in selectedStage!.grades) {
      if (g.track != null && g.track!.trim().isNotEmpty) {
        tracks.add(g.track!.trim());
      }
    }
    return tracks.toList();
  }

  List<CurriculumGradeModel> get availableGrades {
    if (selectedStage == null) return const [];
    final tracks = availableTracks;
    if (tracks.isNotEmpty) {
      if (selectedTrack == null) return const [];
      return selectedStage!.grades.where((g) => g.track?.trim() == selectedTrack).toList();
    }
    return selectedStage!.grades;
  }

  List<CurriculumSubjectModel> get availableSubjects => selectedGrade?.subjects ?? const [];

  int get questionsCount => skills.fold(0, (n, s) => n + s.questions.length);

  bool get allComplete => skills.every((s) => s.name.trim().isNotEmpty && s.questions.every((q) => q.isComplete));

  bool get canGenerate =>
      subjectId != null && !isSourceLoading && (source == null || source!.lessonsCount > 0) && step != DiagnosticStep.writing;

  DiagnosticCreateState copyWith({
    DiagnosticStep? step,
    bool? isStagesLoading,
    String? stagesError,
    bool clearStagesError = false,
    List<CurriculumStageModel>? stages,
    CurriculumStageModel? selectedStage,
    String? selectedTrack,
    bool clearTrack = false,
    CurriculumGradeModel? selectedGrade,
    bool clearGrade = false,
    CurriculumSubjectModel? selectedSubject,
    bool clearSubject = false,
    int? subjectId,
    String? subjectLabel,
    bool? isSourceLoading,
    DiagnosticSource? source,
    bool clearSource = false,
    int? skillsCount,
    int? perSkill,
    String? notes,
    List<DiagnosticSkill>? skills,
    String? title,
    bool? isSaving,
    String? error,
    bool clearError = false,
    int? savedExamId,
  }) =>
      DiagnosticCreateState(
        step: step ?? this.step,
        isStagesLoading: isStagesLoading ?? this.isStagesLoading,
        stagesError: clearStagesError ? null : stagesError ?? this.stagesError,
        stages: stages ?? this.stages,
        selectedStage: selectedStage ?? this.selectedStage,
        selectedTrack: clearTrack ? null : selectedTrack ?? this.selectedTrack,
        selectedGrade: clearGrade ? null : selectedGrade ?? this.selectedGrade,
        selectedSubject: clearSubject ? null : selectedSubject ?? this.selectedSubject,
        subjectId: clearSubject ? null : subjectId ?? this.subjectId,
        subjectLabel: clearSubject ? '' : subjectLabel ?? this.subjectLabel,
        isSourceLoading: isSourceLoading ?? this.isSourceLoading,
        source: clearSource ? null : source ?? this.source,
        skillsCount: skillsCount ?? this.skillsCount,
        perSkill: perSkill ?? this.perSkill,
        notes: notes ?? this.notes,
        skills: skills ?? this.skills,
        title: title ?? this.title,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : error ?? this.error,
        savedExamId: savedExamId ?? this.savedExamId,
      );
}

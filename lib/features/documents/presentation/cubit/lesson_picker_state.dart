part of 'lesson_picker_cubit.dart';

enum LessonPickerStatus { loading, success, failure }

/// The four cascading steps: المرحلة → الصف → المادة → الدرس.
enum LessonPickerStep { stages, grades, subjects, lessons }

class LessonPickerState {
  final LessonPickerStatus status;

  /// The full curriculum tree, loaded once.
  final List<CurriculumStageModel> stages;

  /// Filters the current step's list by name.
  final String query;

  /// The picked stage; null on the stages step.
  final CurriculumStageModel? stage;

  /// The picked grade; null until a stage is open.
  final CurriculumGradeModel? grade;

  /// The open subject; null until a grade is open.
  final CurriculumSubjectModel? subject;
  final LessonPickerStatus lessonsStatus;
  final List<CurriculumChapterModel> chapters;
  final String? errorMessage;

  const LessonPickerState({
    this.status = LessonPickerStatus.loading,
    this.stages = const [],
    this.query = '',
    this.stage,
    this.grade,
    this.subject,
    this.lessonsStatus = LessonPickerStatus.loading,
    this.chapters = const [],
    this.errorMessage,
  });

  LessonPickerStep get step {
    if (stage == null) return LessonPickerStep.stages;
    if (grade == null) return LessonPickerStep.grades;
    if (subject == null) return LessonPickerStep.subjects;
    return LessonPickerStep.lessons;
  }

  List<CurriculumStageModel> get visibleStages => _matching(stages, (stage) => stage.name);

  List<CurriculumGradeModel> get visibleGrades =>
      stage == null ? const [] : _matching(stage!.grades, (grade) => grade.name);

  List<CurriculumSubjectModel> get visibleSubjects =>
      grade == null ? const [] : _matching(grade!.subjects, (subject) => subject.name);

  List<T> _matching<T>(List<T> items, String Function(T) name) {
    final q = query.trim();
    if (q.isEmpty) return items;
    return items.where((item) => name(item).contains(q)).toList();
  }

  LessonPickerState copyWith({
    LessonPickerStatus? status,
    List<CurriculumStageModel>? stages,
    String? query,
    CurriculumStageModel? stage,
    bool clearStage = false,
    CurriculumGradeModel? grade,
    bool clearGrade = false,
    CurriculumSubjectModel? subject,
    bool clearSubject = false,
    LessonPickerStatus? lessonsStatus,
    List<CurriculumChapterModel>? chapters,
    String? errorMessage,
  }) {
    return LessonPickerState(
      status: status ?? this.status,
      stages: stages ?? this.stages,
      query: query ?? this.query,
      stage: clearStage ? null : (stage ?? this.stage),
      grade: clearGrade ? null : (grade ?? this.grade),
      subject: clearSubject ? null : (subject ?? this.subject),
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      chapters: chapters ?? this.chapters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

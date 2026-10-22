part of 'lesson_picker_cubit.dart';

enum LessonPickerStatus { loading, success, failure }

class LessonPickerState {
  final LessonPickerStatus status;
  final List<LessonPickerSubjectModel> subjects;
  final String query;

  /// The open subject; null on the subjects step.
  final LessonPickerSubjectModel? subject;
  final LessonPickerStatus lessonsStatus;
  final List<CurriculumChapterModel> chapters;
  final String? errorMessage;

  const LessonPickerState({
    this.status = LessonPickerStatus.loading,
    this.subjects = const [],
    this.query = '',
    this.subject,
    this.lessonsStatus = LessonPickerStatus.loading,
    this.chapters = const [],
    this.errorMessage,
  });

  List<LessonPickerSubjectModel> get visibleSubjects =>
      subjects.where((subject) => subject.matches(query)).toList();

  LessonPickerState copyWith({
    LessonPickerStatus? status,
    List<LessonPickerSubjectModel>? subjects,
    String? query,
    LessonPickerSubjectModel? subject,
    bool clearSubject = false,
    LessonPickerStatus? lessonsStatus,
    List<CurriculumChapterModel>? chapters,
    String? errorMessage,
  }) {
    return LessonPickerState(
      status: status ?? this.status,
      subjects: subjects ?? this.subjects,
      query: query ?? this.query,
      subject: clearSubject ? null : (subject ?? this.subject),
      lessonsStatus: lessonsStatus ?? this.lessonsStatus,
      chapters: chapters ?? this.chapters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

part of 'class_editor_cubit.dart';

enum ClassEditorStatus { loading, success, failure }

class ClassEditorState {
  final ClassEditorStatus status;
  final String? errorMessage;

  /// Null until a new class is first saved.
  final int? classId;
  final List<String> students;
  final bool isImporting;
  final bool isSaving;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final List<String>? importedNames;
  final bool isSaved;
  final UiFeedback? feedback;

  const ClassEditorState({
    this.status = ClassEditorStatus.loading,
    this.errorMessage,
    this.classId,
    this.students = const [],
    this.isImporting = false,
    this.isSaving = false,
    this.importedNames,
    this.isSaved = false,
    this.feedback,
  });

  bool get isFull => students.length >= ClassLimits.maxStudents;

  ClassEditorState copyWith({
    ClassEditorStatus? status,
    String? errorMessage,
    int? classId,
    List<String>? students,
    bool? isImporting,
    bool? isSaving,
    List<String>? importedNames,
    bool isSaved = false,
    UiFeedback? feedback,
  }) {
    return ClassEditorState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      classId: classId ?? this.classId,
      students: students ?? this.students,
      isImporting: isImporting ?? this.isImporting,
      isSaving: isSaving ?? this.isSaving,
      importedNames: importedNames,
      isSaved: isSaved,
      feedback: feedback,
    );
  }
}

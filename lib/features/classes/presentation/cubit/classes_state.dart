part of 'classes_cubit.dart';

enum ClassesStatus { loading, success, failure }

class ClassesState {
  final ClassesStatus status;
  final List<SchoolClassModel> classes;
  final String? errorMessage;

  /// The class being deleted.
  final int? busyId;

  /// One-shot, cleared by [copyWith] unless passed.
  final UiFeedback? feedback;

  const ClassesState({
    this.status = ClassesStatus.loading,
    this.classes = const [],
    this.errorMessage,
    this.busyId,
    this.feedback,
  });

  bool get isFull => classes.length >= ClassLimits.maxClasses;

  ClassesState copyWith({
    ClassesStatus? status,
    List<SchoolClassModel>? classes,
    String? errorMessage,
    int? busyId,
    bool clearBusy = false,
    UiFeedback? feedback,
  }) {
    return ClassesState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      errorMessage: errorMessage ?? this.errorMessage,
      busyId: clearBusy ? null : (busyId ?? this.busyId),
      feedback: feedback,
    );
  }
}

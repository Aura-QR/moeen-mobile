part of 'lab_lesson_actions_cubit.dart';

@immutable
class LabLessonActionsState {
  final bool isSubmitting;
  final String displayMode;
  final int variablesCount;
  final int readingsCount;
  final LabExperimentModel? createdExperiment;
  final UiFeedback? feedback;
  final List<String> validationErrors;

  const LabLessonActionsState({
    this.isSubmitting = false,
    this.displayMode = 'bars',
    this.variablesCount = 1,
    this.readingsCount = 1,
    this.createdExperiment,
    this.feedback,
    this.validationErrors = const [],
  });

  LabLessonActionsState copyWith({
    bool? isSubmitting,
    String? displayMode,
    int? variablesCount,
    int? readingsCount,
    LabExperimentModel? createdExperiment,
    UiFeedback? feedback,
    List<String>? validationErrors,
  }) {
    return LabLessonActionsState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      displayMode: displayMode ?? this.displayMode,
      variablesCount: variablesCount ?? this.variablesCount,
      readingsCount: readingsCount ?? this.readingsCount,
      createdExperiment: createdExperiment ?? this.createdExperiment,
      feedback: feedback,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

part of 'outcomes_map_editor_cubit.dart';

enum OutcomesMapEditorStatus { loading, success, failure }

/// Per-unit progress while «✨ اقترح النواتج» runs.
enum UnitAiStatus { idle, running, done, failed }

/// Points at one lesson inside the map (unit index + lesson index).
class LessonRef extends Equatable {
  final int unitIndex;
  final int lessonIndex;

  const LessonRef(this.unitIndex, this.lessonIndex);

  String get key => '$unitIndex-$lessonIndex';

  @override
  List<Object?> get props => [unitIndex, lessonIndex];
}

class OutcomesMapEditorState {
  final OutcomesMapEditorStatus status;
  final int? documentId;
  final String documentStatus;
  final DocumentDefaultsModel defaults;
  final OutcomesMapInput input;
  final bool isDirty;
  final bool isSaving;
  final String? titleError;
  final Map<int, String> unitErrors;
  final Map<String, String> lessonErrors;
  final LessonRef? openLesson;

  /// Per-unit AI state for the «اقترح النواتج» progress.
  final Map<int, UnitAiStatus> unitAiStatus;
  final bool isSuggestingAll;
  final int aiCurrentUnit;
  final int aiTotalUnits;

  /// The lesson whose own «اقترح لهذا الدرس» is running, if any.
  final LessonRef? aiBusyLesson;

  final DocumentFollowUp? followUp;
  final PaymentRequiredFailure? paymentRequired;
  final String? errorMessage;
  final UiFeedback? feedback;

  const OutcomesMapEditorState({
    this.status = OutcomesMapEditorStatus.loading,
    this.documentId,
    this.documentStatus = DocumentStatus.draft,
    this.defaults = const DocumentDefaultsModel(),
    this.input = const OutcomesMapInput(),
    this.isDirty = false,
    this.isSaving = false,
    this.titleError,
    this.unitErrors = const {},
    this.lessonErrors = const {},
    this.openLesson,
    this.unitAiStatus = const {},
    this.isSuggestingAll = false,
    this.aiCurrentUnit = 0,
    this.aiTotalUnits = 0,
    this.aiBusyLesson,
    this.followUp,
    this.paymentRequired,
    this.errorMessage,
    this.feedback,
  });

  bool get isAiBusy => isSuggestingAll || aiBusyLesson != null;

  UnitAiStatus unitStatus(int index) => unitAiStatus[index] ?? UnitAiStatus.idle;

  OutcomesMapEditorState copyWith({
    OutcomesMapEditorStatus? status,
    int? documentId,
    String? documentStatus,
    DocumentDefaultsModel? defaults,
    OutcomesMapInput? input,
    bool? isDirty,
    bool? isSaving,
    String? titleError,
    bool clearTitleError = false,
    Map<int, String>? unitErrors,
    Map<String, String>? lessonErrors,
    LessonRef? openLesson,
    Map<int, UnitAiStatus>? unitAiStatus,
    bool? isSuggestingAll,
    int? aiCurrentUnit,
    int? aiTotalUnits,
    LessonRef? aiBusyLesson,
    DocumentFollowUp? followUp,
    PaymentRequiredFailure? paymentRequired,
    String? errorMessage,
    UiFeedback? feedback,
  }) {
    return OutcomesMapEditorState(
      status: status ?? this.status,
      documentId: documentId ?? this.documentId,
      documentStatus: documentStatus ?? this.documentStatus,
      defaults: defaults ?? this.defaults,
      input: input ?? this.input,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      unitErrors: unitErrors ?? this.unitErrors,
      lessonErrors: lessonErrors ?? this.lessonErrors,
      openLesson: openLesson,
      unitAiStatus: unitAiStatus ?? this.unitAiStatus,
      isSuggestingAll: isSuggestingAll ?? this.isSuggestingAll,
      aiCurrentUnit: aiCurrentUnit ?? this.aiCurrentUnit,
      aiTotalUnits: aiTotalUnits ?? this.aiTotalUnits,
      aiBusyLesson: aiBusyLesson,
      followUp: followUp,
      paymentRequired: paymentRequired,
      errorMessage: errorMessage ?? this.errorMessage,
      feedback: feedback,
    );
  }
}

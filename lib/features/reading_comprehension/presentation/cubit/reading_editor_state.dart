part of 'reading_editor_cubit.dart';

enum ReadingEditorStatus { loading, success, failure }

class ReadingEditorState {
  final ReadingEditorStatus status;
  final int? documentId;
  final String documentStatus;
  final DocumentDefaultsModel defaults;
  final ReadingComprehensionInput input;
  final bool isDirty;
  final bool isSaving;
  final bool isSharing;
  final String? titleError;
  final Map<int, String> passageErrors;
  final Map<int, String> vocabularyErrors;
  final Map<int, String> questionErrors;

  /// One-off: open the question editor sheet at this index.
  final int? openQuestionIndex;

  /// One-off: the follow-up sheet to open after a successful save.
  final DocumentFollowUp? followUp;

  /// One-off: the exam the worksheet was copied into, to continue the share flow.
  final DocumentExamRef? shareExamRef;
  final PaymentRequiredFailure? paymentRequired;
  final String? errorMessage;
  final UiFeedback? feedback;

  const ReadingEditorState({
    this.status = ReadingEditorStatus.loading,
    this.documentId,
    this.documentStatus = DocumentStatus.draft,
    this.defaults = const DocumentDefaultsModel(),
    this.input = const ReadingComprehensionInput(),
    this.isDirty = false,
    this.isSaving = false,
    this.isSharing = false,
    this.titleError,
    this.passageErrors = const {},
    this.vocabularyErrors = const {},
    this.questionErrors = const {},
    this.openQuestionIndex,
    this.followUp,
    this.shareExamRef,
    this.paymentRequired,
    this.errorMessage,
    this.feedback,
  });

  ReadingEditorState copyWith({
    ReadingEditorStatus? status,
    int? documentId,
    String? documentStatus,
    DocumentDefaultsModel? defaults,
    ReadingComprehensionInput? input,
    bool? isDirty,
    bool? isSaving,
    bool? isSharing,
    String? titleError,
    bool clearTitleError = false,
    Map<int, String>? passageErrors,
    Map<int, String>? vocabularyErrors,
    Map<int, String>? questionErrors,
    bool clearErrors = false,
    int? openQuestionIndex,
    DocumentFollowUp? followUp,
    DocumentExamRef? shareExamRef,
    PaymentRequiredFailure? paymentRequired,
    String? errorMessage,
    UiFeedback? feedback,
  }) {
    return ReadingEditorState(
      status: status ?? this.status,
      documentId: documentId ?? this.documentId,
      documentStatus: documentStatus ?? this.documentStatus,
      defaults: defaults ?? this.defaults,
      input: input ?? this.input,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      isSharing: isSharing ?? this.isSharing,
      titleError: clearTitleError || clearErrors ? null : (titleError ?? this.titleError),
      passageErrors: clearErrors ? const {} : (passageErrors ?? this.passageErrors),
      vocabularyErrors: clearErrors ? const {} : (vocabularyErrors ?? this.vocabularyErrors),
      questionErrors: clearErrors ? const {} : (questionErrors ?? this.questionErrors),
      openQuestionIndex: openQuestionIndex,
      followUp: followUp,
      shareExamRef: shareExamRef,
      paymentRequired: paymentRequired,
      errorMessage: errorMessage ?? this.errorMessage,
      feedback: feedback,
    );
  }
}

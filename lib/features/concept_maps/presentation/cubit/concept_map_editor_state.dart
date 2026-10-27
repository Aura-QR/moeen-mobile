part of 'concept_map_editor_cubit.dart';

enum ConceptMapEditorStatus { loading, success, failure }

class ConceptMapEditorState {
  final ConceptMapEditorStatus status;
  final int? documentId;
  final String documentStatus;
  final DocumentDefaultsModel defaults;
  final ConceptMapInput input;
  final bool isDirty;
  final bool isSaving;
  final String? titleError;
  final Map<String, String> nodeErrors;
  final String? openNodeSheetId;
  final DocumentFollowUp? followUp;
  final PaymentRequiredFailure? paymentRequired;
  final String? errorMessage;
  final UiFeedback? feedback;

  const ConceptMapEditorState({
    this.status = ConceptMapEditorStatus.loading,
    this.documentId,
    this.documentStatus = DocumentStatus.draft,
    this.defaults = const DocumentDefaultsModel(),
    this.input = const ConceptMapInput(nodes: [ConceptMapNode(id: 'n1')]),
    this.isDirty = false,
    this.isSaving = false,
    this.titleError,
    this.nodeErrors = const {},
    this.openNodeSheetId,
    this.followUp,
    this.paymentRequired,
    this.errorMessage,
    this.feedback,
  });

  ConceptMapEditorState copyWith({
    ConceptMapEditorStatus? status,
    int? documentId,
    String? documentStatus,
    DocumentDefaultsModel? defaults,
    ConceptMapInput? input,
    bool? isDirty,
    bool? isSaving,
    String? titleError,
    bool clearTitleError = false,
    Map<String, String>? nodeErrors,
    String? openNodeSheetId,
    DocumentFollowUp? followUp,
    PaymentRequiredFailure? paymentRequired,
    String? errorMessage,
    UiFeedback? feedback,
  }) {
    return ConceptMapEditorState(
      status: status ?? this.status,
      documentId: documentId ?? this.documentId,
      documentStatus: documentStatus ?? this.documentStatus,
      defaults: defaults ?? this.defaults,
      input: input ?? this.input,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      nodeErrors: nodeErrors ?? this.nodeErrors,
      openNodeSheetId: openNodeSheetId,
      followUp: followUp,
      paymentRequired: paymentRequired,
      errorMessage: errorMessage ?? this.errorMessage,
      feedback: feedback,
    );
  }
}

part of 'report_editor_cubit.dart';

enum ReportEditorStatus { loading, success, failure }

class ReportEditorState {
  static const int maxSignatures = 4;

  final ReportEditorStatus status;
  final String? errorMessage;
  final ReportCatalogueModel? catalogue;

  /// The form; the title lives in the cubit's controller until saving.
  final ReportInput input;

  /// Every photo of the report, shown with its signed URL or picked bytes.
  final List<DocumentImageModel> images;
  final int? documentId;
  final String documentStatus;
  final bool isSaving;
  final bool isUploadingImage;

  /// Something changed since the last save.
  final bool isDirty;

  /// Block id → message, from the last save attempt.
  final Map<int, String> blockErrors;
  final String? titleError;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final int? scrollToBlockId;
  final DocumentFollowUp? followUp;
  final UiFeedback? feedback;

  const ReportEditorState({
    this.status = ReportEditorStatus.loading,
    this.errorMessage,
    this.catalogue,
    this.input = const ReportInput(),
    this.images = const [],
    this.documentId,
    this.documentStatus = DocumentStatus.draft,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.isDirty = false,
    this.blockErrors = const {},
    this.titleError,
    this.scrollToBlockId,
    this.followUp,
    this.feedback,
  });

  ReportLimitsModel get limits => catalogue?.limits ?? const ReportLimitsModel();

  /// The «إضافة» menu: the server's order, or ours.
  List<String> get blockKinds {
    final kinds = catalogue?.blockKinds.map((k) => k.kind).toList() ?? const [];
    return kinds.isEmpty ? ReportBlockKinds.all : kinds;
  }

  ReportEditorState copyWith({
    ReportEditorStatus? status,
    String? errorMessage,
    ReportCatalogueModel? catalogue,
    ReportInput? input,
    List<DocumentImageModel>? images,
    int? documentId,
    String? documentStatus,
    bool? isSaving,
    bool? isUploadingImage,
    bool? isDirty,
    Map<int, String>? blockErrors,
    String? titleError,
    bool clearTitleError = false,
    int? scrollToBlockId,
    DocumentFollowUp? followUp,
    UiFeedback? feedback,
  }) {
    return ReportEditorState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      catalogue: catalogue ?? this.catalogue,
      input: input ?? this.input,
      images: images ?? this.images,
      documentId: documentId ?? this.documentId,
      documentStatus: documentStatus ?? this.documentStatus,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isDirty: isDirty ?? this.isDirty,
      blockErrors: blockErrors ?? this.blockErrors,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      scrollToBlockId: scrollToBlockId,
      followUp: followUp,
      feedback: feedback,
    );
  }
}

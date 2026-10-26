part of 'report_editor_cubit.dart';

enum ReportEditorStatus { loading, success, failure }

enum RoleAiStatus { idle, writing, done, failed, rateLimited }

class ReportEditorState {
  static const int maxSignatures = 4;
  static const int maxBriefChars = 600;

  final ReportEditorStatus status;
  final String? errorMessage;
  final ReportCatalogueModel? catalogue;

  /// Role document metadata when opened from «حقائب الأدوار» (or reopened with `role`+`doc`).
  final RoleDocumentTemplateModel? roleTemplate;

  /// Teacher's document defaults (`gender_form` is sent to `POST /ai-jobs`).
  final DocumentDefaultsModel defaults;

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

  /// «✨ اكتب لي» AI generation state.
  final RoleAiStatus aiStatus;
  final String? aiErrorMessage;
  final bool canUndoAi;
  final int briefLength;
  final String aiDate;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final int? scrollToBlockId;
  final DocumentFollowUp? followUp;
  final UiFeedback? feedback;
  final PaymentRequiredFailure? paymentRequired;

  const ReportEditorState({
    this.status = ReportEditorStatus.loading,
    this.errorMessage,
    this.catalogue,
    this.roleTemplate,
    this.defaults = const DocumentDefaultsModel(),
    this.input = const ReportInput(),
    this.images = const [],
    this.documentId,
    this.documentStatus = DocumentStatus.draft,
    this.isSaving = false,
    this.isUploadingImage = false,
    this.isDirty = false,
    this.blockErrors = const {},
    this.titleError,
    this.aiStatus = RoleAiStatus.idle,
    this.aiErrorMessage,
    this.canUndoAi = false,
    this.briefLength = 0,
    this.aiDate = '',
    this.scrollToBlockId,
    this.followUp,
    this.feedback,
    this.paymentRequired,
  });

  ReportLimitsModel get limits => catalogue?.limits ?? const ReportLimitsModel();

  bool get isRoleDocument => roleTemplate != null;

  bool get isSensitive => roleTemplate?.sensitive == true;

  bool get canUseAi => (roleTemplate?.ai == true) && !isSensitive;

  bool get isAiWriting => aiStatus == RoleAiStatus.writing;

  String get briefHint => roleTemplate?.briefHint ?? '';

  /// The «إضافة» menu: the server's order, or ours (without `images` on sensitive forms).
  List<String> get blockKinds {
    final kinds = catalogue?.blockKinds.map((k) => k.kind).toList() ?? const [];
    final base = kinds.isEmpty ? ReportBlockKinds.all : kinds;
    if (!isSensitive) return base;
    return base.where((k) => k != ReportBlockKinds.images).toList();
  }

  /// Resolved 0-based column index for «من فصولي» on [block], or null when unset / sensitive.
  int? namesColumnFor(TableBlock block) {
    if (isSensitive) return null;
    if (block.namesColumn != null) {
      return resolveNamesColumnIndex(block.namesColumn, block.columns);
    }
    final raw = roleTemplate?.namesColumn;
    if (raw == null) return null;
    for (final candidate in input.blocks.whereType<TableBlock>()) {
      final resolved = resolveNamesColumnIndex(raw, candidate.columns);
      if (resolved != null) {
        return candidate.id == block.id ? resolved : null;
      }
    }
    return null;
  }

  ReportEditorState copyWith({
    ReportEditorStatus? status,
    String? errorMessage,
    ReportCatalogueModel? catalogue,
    RoleDocumentTemplateModel? roleTemplate,
    DocumentDefaultsModel? defaults,
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
    RoleAiStatus? aiStatus,
    String? aiErrorMessage,
    bool clearAiError = false,
    bool? canUndoAi,
    int? briefLength,
    String? aiDate,
    int? scrollToBlockId,
    DocumentFollowUp? followUp,
    UiFeedback? feedback,
    PaymentRequiredFailure? paymentRequired,
  }) {
    return ReportEditorState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      catalogue: catalogue ?? this.catalogue,
      roleTemplate: roleTemplate ?? this.roleTemplate,
      defaults: defaults ?? this.defaults,
      input: input ?? this.input,
      images: images ?? this.images,
      documentId: documentId ?? this.documentId,
      documentStatus: documentStatus ?? this.documentStatus,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isDirty: isDirty ?? this.isDirty,
      blockErrors: blockErrors ?? this.blockErrors,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
      aiStatus: aiStatus ?? this.aiStatus,
      aiErrorMessage: clearAiError ? null : (aiErrorMessage ?? this.aiErrorMessage),
      canUndoAi: canUndoAi ?? this.canUndoAi,
      briefLength: briefLength ?? this.briefLength,
      aiDate: aiDate ?? this.aiDate,
      scrollToBlockId: scrollToBlockId,
      followUp: followUp,
      feedback: feedback,
      paymentRequired: paymentRequired,
    );
  }
}

part of 'grade_analysis_cubit.dart';

enum GradeAnalysisStatus { loading, success, failure }

class GradeAnalysisState {
  final GradeAnalysisStatus status;
  final String? errorMessage;

  /// Null until the first save; later saves PATCH it.
  final int? documentId;
  final GradeOptionsModel options;
  final DocumentDefaultsModel defaults;

  /// A [GradeReportTypes] value.
  final String reportType;
  final DateTime? date;

  /// «مستويات الأداء», highest first; the lowest starts at 0.
  final List<GradeBand> bands;

  /// 1 to 5 class tabs; the text is in the cubit's [GradeClassesEditor].
  final List<GradeClassLayout> classes;
  final int activeClass;

  /// «التوصيات»: only the ticked lines are saved.
  final ChecklistSection recommendations;
  final bool isImporting;
  final bool isDeletingAll;
  final bool isOverridingHeader;
  final List<DocumentImageModel> images;
  final bool isUploadingImage;
  final DocumentTheme theme;

  /// «مسودة» or «نهائي».
  final String documentStatus;
  final bool isSaving;

  /// Grows with every change to the numbers, so the screen re-analyses.
  final int revision;

  /// One-shot fields, cleared by [copyWith] unless passed.
  /// [importedSheet] is the sheet read from Excel, for review.
  final GradeSheetImport? importedSheet;
  final DocumentFollowUp? followUp;
  final UiFeedback? feedback;

  static const String recommendationsKey = 'recommendations';

  const GradeAnalysisState({
    this.status = GradeAnalysisStatus.loading,
    this.errorMessage,
    this.documentId,
    this.options = const GradeOptionsModel(),
    this.defaults = const DocumentDefaultsModel(),
    this.reportType = GradeReportTypes.quick,
    this.date,
    this.bands = const [],
    this.classes = const [],
    this.activeClass = 0,
    this.recommendations = const ChecklistSection(
      key: recommendationsKey,
      label: '',
      maxChecked: GradeLimits.recommendations,
      maxLength: GradeLimits.recommendationLength,
    ),
    this.isImporting = false,
    this.isDeletingAll = false,
    this.isOverridingHeader = false,
    this.images = const [],
    this.isUploadingImage = false,
    this.theme = DocumentTheme.teal,
    this.documentStatus = DocumentStatus.draft,
    this.isSaving = false,
    this.revision = 0,
    this.importedSheet,
    this.followUp,
    this.feedback,
  });

  bool get isDetailed => reportType == GradeReportTypes.detailed;

  GradeClassLayout? get active => activeClass < classes.length ? classes[activeClass] : null;

  bool get canAddClass => classes.length < options.limits.classes;

  bool get isBusy => isSaving || isUploadingImage || isImporting || isDeletingAll;

  GradeAnalysisState copyWith({
    GradeAnalysisStatus? status,
    String? errorMessage,
    int? documentId,
    bool clearDocumentId = false,
    GradeOptionsModel? options,
    DocumentDefaultsModel? defaults,
    String? reportType,
    DateTime? date,
    List<GradeBand>? bands,
    List<GradeClassLayout>? classes,
    int? activeClass,
    ChecklistSection? recommendations,
    bool? isImporting,
    bool? isDeletingAll,
    bool? isOverridingHeader,
    List<DocumentImageModel>? images,
    bool? isUploadingImage,
    DocumentTheme? theme,
    String? documentStatus,
    bool? isSaving,
    int? revision,
    GradeSheetImport? importedSheet,
    DocumentFollowUp? followUp,
    UiFeedback? feedback,
  }) {
    return GradeAnalysisState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      documentId: clearDocumentId ? null : (documentId ?? this.documentId),
      options: options ?? this.options,
      defaults: defaults ?? this.defaults,
      reportType: reportType ?? this.reportType,
      date: date ?? this.date,
      bands: bands ?? this.bands,
      classes: classes ?? this.classes,
      activeClass: activeClass ?? this.activeClass,
      recommendations: recommendations ?? this.recommendations,
      isImporting: isImporting ?? this.isImporting,
      isDeletingAll: isDeletingAll ?? this.isDeletingAll,
      isOverridingHeader: isOverridingHeader ?? this.isOverridingHeader,
      images: images ?? this.images,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      theme: theme ?? this.theme,
      documentStatus: documentStatus ?? this.documentStatus,
      isSaving: isSaving ?? this.isSaving,
      revision: revision ?? this.revision,
      importedSheet: importedSheet,
      followUp: followUp,
      feedback: feedback,
    );
  }
}

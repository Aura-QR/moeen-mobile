part of 'strategy_documentation_cubit.dart';

enum StrategyDocumentationStatus { loading, success, failure }

/// What to open once a save succeeds.
enum StrategyFollowUp { export, attachToPortfolio }

class StrategyDocumentationState {
  final StrategyDocumentationStatus status;
  final String? errorMessage;

  /// Null until the first save; later saves PATCH it.
  final int? documentId;
  final StrategyCatalogueModel catalogue;
  final DocumentDefaultsModel defaults;
  final String? strategyKey;

  /// The catalogue texts, for «استعادة النص الأصلي».
  final StrategyDetailsModel? strategy;
  final bool isLoadingStrategy;
  final Map<StrategyListSection, List<String>> lists;
  final DateTime? executionDate;
  final bool isOverridingHeader;
  final List<DocumentImageModel> images;
  final bool isUploadingImage;
  final DocumentTheme theme;

  /// «مسودة» or «نهائي».
  final String documentStatus;
  final bool isSaving;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final StrategyFollowUp? followUp;
  final UiFeedback? feedback;

  const StrategyDocumentationState({
    this.status = StrategyDocumentationStatus.loading,
    this.errorMessage,
    this.documentId,
    this.catalogue = const StrategyCatalogueModel(),
    this.defaults = const DocumentDefaultsModel(),
    this.strategyKey,
    this.strategy,
    this.isLoadingStrategy = false,
    this.lists = const {},
    this.executionDate,
    this.isOverridingHeader = false,
    this.images = const [],
    this.isUploadingImage = false,
    this.theme = DocumentTheme.teal,
    this.documentStatus = DocumentStatus.draft,
    this.isSaving = false,
    this.followUp,
    this.feedback,
  });

  List<String> listOf(StrategyListSection section) => lists[section] ?? const [];

  String? get strategyName => strategy?.name ?? catalogue.byKey(strategyKey)?.name;

  StrategyDocumentationState copyWith({
    StrategyDocumentationStatus? status,
    String? errorMessage,
    int? documentId,
    StrategyCatalogueModel? catalogue,
    DocumentDefaultsModel? defaults,
    String? strategyKey,
    StrategyDetailsModel? strategy,
    bool clearStrategy = false,
    bool? isLoadingStrategy,
    Map<StrategyListSection, List<String>>? lists,
    DateTime? executionDate,
    bool? isOverridingHeader,
    List<DocumentImageModel>? images,
    bool? isUploadingImage,
    DocumentTheme? theme,
    String? documentStatus,
    bool? isSaving,
    StrategyFollowUp? followUp,
    UiFeedback? feedback,
  }) {
    return StrategyDocumentationState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      documentId: documentId ?? this.documentId,
      catalogue: catalogue ?? this.catalogue,
      defaults: defaults ?? this.defaults,
      strategyKey: strategyKey ?? this.strategyKey,
      strategy: clearStrategy ? null : (strategy ?? this.strategy),
      isLoadingStrategy: isLoadingStrategy ?? this.isLoadingStrategy,
      lists: lists ?? this.lists,
      executionDate: executionDate ?? this.executionDate,
      isOverridingHeader: isOverridingHeader ?? this.isOverridingHeader,
      images: images ?? this.images,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      theme: theme ?? this.theme,
      documentStatus: documentStatus ?? this.documentStatus,
      isSaving: isSaving ?? this.isSaving,
      followUp: followUp,
      feedback: feedback,
    );
  }
}

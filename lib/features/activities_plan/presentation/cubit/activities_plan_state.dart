part of 'activities_plan_cubit.dart';

enum ActivitiesPlanStatus { loading, success, failure }

enum ActivitiesGridStatus { idle, loading, success, failure }

class ActivitiesPlanState {
  final ActivitiesPlanStatus status;
  final String? errorMessage;

  /// Null until the first save; later saves PATCH it.
  final int? documentId;
  final ActivitiesCatalogueModel catalogue;
  final DocumentDefaultsModel defaults;
  final String? stage;
  final int term;

  /// Domain keys in column order.
  final List<String> domains;

  /// Null uses the teacher's `region_calendar`.
  final String? region;
  final ActivitiesGridStatus gridStatus;
  final ActivitiesGridModel? grid;
  final String? gridError;

  /// The teacher's changes: week number → column key → text.
  final Map<int, Map<String, String>> cells;
  final bool isOverridingHeader;
  final List<DocumentImageModel> images;
  final bool isUploadingImage;
  final DocumentTheme theme;

  /// «مسودة» or «نهائي».
  final String documentStatus;
  final bool isSaving;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final DocumentFollowUp? followUp;
  final UiFeedback? feedback;

  const ActivitiesPlanState({
    this.status = ActivitiesPlanStatus.loading,
    this.errorMessage,
    this.documentId,
    this.catalogue = const ActivitiesCatalogueModel(),
    this.defaults = const DocumentDefaultsModel(),
    this.stage,
    this.term = 1,
    this.domains = const [],
    this.region,
    this.gridStatus = ActivitiesGridStatus.idle,
    this.grid,
    this.gridError,
    this.cells = const {},
    this.isOverridingHeader = false,
    this.images = const [],
    this.isUploadingImage = false,
    this.theme = DocumentTheme.teal,
    this.documentStatus = DocumentStatus.draft,
    this.isSaving = false,
    this.followUp,
    this.feedback,
  });

  /// The calendar in use: the teacher's pick, else the grid's, else the defaults'.
  String get effectiveRegion => region ?? grid?.region ?? defaults.regionCalendar.name;

  /// The teacher's text when changed, else the suggestion.
  String textOf(ActivitiesWeekModel week, String column) =>
      cells[week.week]?[column] ?? week.cells[column] ?? '';

  bool isEdited(ActivitiesWeekModel week, String column) => cells[week.week]?.containsKey(column) ?? false;

  ActivitiesPlanState copyWith({
    ActivitiesPlanStatus? status,
    String? errorMessage,
    int? documentId,
    ActivitiesCatalogueModel? catalogue,
    DocumentDefaultsModel? defaults,
    String? stage,
    int? term,
    List<String>? domains,
    String? region,
    ActivitiesGridStatus? gridStatus,
    ActivitiesGridModel? grid,
    String? gridError,
    Map<int, Map<String, String>>? cells,
    bool? isOverridingHeader,
    List<DocumentImageModel>? images,
    bool? isUploadingImage,
    DocumentTheme? theme,
    String? documentStatus,
    bool? isSaving,
    DocumentFollowUp? followUp,
    UiFeedback? feedback,
  }) {
    return ActivitiesPlanState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      documentId: documentId ?? this.documentId,
      catalogue: catalogue ?? this.catalogue,
      defaults: defaults ?? this.defaults,
      stage: stage ?? this.stage,
      term: term ?? this.term,
      domains: domains ?? this.domains,
      region: region ?? this.region,
      gridStatus: gridStatus ?? this.gridStatus,
      grid: grid ?? this.grid,
      gridError: gridError ?? this.gridError,
      cells: cells ?? this.cells,
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

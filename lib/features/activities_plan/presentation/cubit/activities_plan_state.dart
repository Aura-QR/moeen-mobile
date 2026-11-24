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

  /// True for a document saved before the official layout; it keeps the old
  /// form (stage and domains). Every new plan is official.
  final bool isLegacy;

  /// The official layout's band, and its periods per week (null: the band's default).
  final String? band;
  final int? periodsPerWeek;

  /// The old layout's stage.
  final String? stage;
  final int term;

  /// The old layout's domain keys in column order.
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
    this.isLegacy = false,
    this.band,
    this.periodsPerWeek,
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

  bool get isOfficial => !isLegacy;

  /// The stepper's value: the teacher's pick, else the band's default.
  int get effectivePeriodsPerWeek => periodsPerWeek ?? catalogue.bandOf(band)?.periodsPerWeek ?? 1;

  /// Periods per domain over the teaching weeks, as the teacher has them now,
  /// against the term's target. Null for the old layout.
  ActivitiesSummaryModel? get officialSummary {
    final grid = this.grid;
    if (isLegacy || grid == null) return null;
    final totals = <String, int>{};
    for (final week in grid.weeks) {
      if (week.type != ActivitiesWeekType.teaching || week.week == null) continue;
      final domain = textOf(week, ActivitiesColumns.domain);
      if (domain.isEmpty) continue;
      totals[domain] = (totals[domain] ?? 0) + (int.tryParse(textOf(week, ActivitiesColumns.periods)) ?? 0);
    }
    return ActivitiesSummaryModel(
      domains: [
        for (final domain in catalogue.officialDomains)
          ActivitiesSummaryDomainModel(key: domain.key, label: domain.label, periods: totals[domain.key] ?? 0),
      ],
      total: totals.values.fold(0, (sum, periods) => sum + periods),
      target: grid.summary?.target ?? 0,
    );
  }

  /// The teacher's text when changed, else the suggestion.
  String textOf(ActivitiesWeekModel week, String column) => cells[week.week]?[column] ?? week.cells[column] ?? '';

  bool isEdited(ActivitiesWeekModel week, String column) => cells[week.week]?.containsKey(column) ?? false;

  ActivitiesPlanState copyWith({
    ActivitiesPlanStatus? status,
    String? errorMessage,
    int? documentId,
    ActivitiesCatalogueModel? catalogue,
    DocumentDefaultsModel? defaults,
    bool? isLegacy,
    String? band,
    int? periodsPerWeek,
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
      isLegacy: isLegacy ?? this.isLegacy,
      band: band ?? this.band,
      periodsPerWeek: periodsPerWeek ?? this.periodsPerWeek,
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

part of 'lab_library_cubit.dart';

enum LabLibraryStatus { initial, loading, success, failure }

@immutable
class LabLibraryState {
  final LabLibraryStatus status;
  final List<LabExperimentModel> experiments;
  final LabFiltersModel? filters;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  final UiFeedback? feedback;

  // Filter selections
  final int? selectedStageId;
  final int? selectedGradeId;
  final int? selectedSubjectId;
  final String? selectedSubjectGroup;
  final String sort; // 'popular' | 'name'
  final int? lessonId;
  final String? lessonTitle;

  const LabLibraryState({
    this.status = LabLibraryStatus.initial,
    this.experiments = const [],
    this.filters,
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.feedback,
    this.selectedStageId,
    this.selectedGradeId,
    this.selectedSubjectId,
    this.selectedSubjectGroup,
    this.sort = 'popular',
    this.lessonId,
    this.lessonTitle,
  });

  bool get hasActiveFilters =>
      selectedStageId != null ||
      selectedGradeId != null ||
      selectedSubjectId != null ||
      (selectedSubjectGroup != null && selectedSubjectGroup!.isNotEmpty);

  LabLibraryState copyWith({
    LabLibraryStatus? status,
    List<LabExperimentModel>? experiments,
    LabFiltersModel? filters,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
    UiFeedback? feedback,
    int? selectedStageId,
    bool clearStage = false,
    int? selectedGradeId,
    bool clearGrade = false,
    int? selectedSubjectId,
    bool clearSubject = false,
    String? selectedSubjectGroup,
    bool clearSubjectGroup = false,
    String? sort,
    int? lessonId,
    bool clearLesson = false,
    String? lessonTitle,
  }) {
    return LabLibraryState(
      status: status ?? this.status,
      experiments: experiments ?? this.experiments,
      filters: filters ?? this.filters,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      feedback: feedback,
      selectedStageId:
          clearStage ? null : (selectedStageId ?? this.selectedStageId),
      selectedGradeId:
          clearGrade ? null : (selectedGradeId ?? this.selectedGradeId),
      selectedSubjectId:
          clearSubject ? null : (selectedSubjectId ?? this.selectedSubjectId),
      selectedSubjectGroup: clearSubjectGroup
          ? null
          : (selectedSubjectGroup ?? this.selectedSubjectGroup),
      sort: sort ?? this.sort,
      lessonId: clearLesson ? null : (lessonId ?? this.lessonId),
      lessonTitle: clearLesson ? null : (lessonTitle ?? this.lessonTitle),
    );
  }
}

part of 'new_outcomes_map_cubit.dart';

class NewOutcomesMapState {
  final bool isStagesLoading;
  final String? stagesError;
  final List<CurriculumStageModel> stages;
  final CurriculumStageModel? selectedStage;
  final String? selectedTrack;
  final CurriculumGradeModel? selectedGrade;
  final CurriculumSubjectModel? selectedSubject;
  final bool isLessonsLoading;
  final String? lessonsError;
  final List<CurriculumChapterModel> chapters;
  final String semester;
  final OutcomesMapInput? generatedInput;

  const NewOutcomesMapState({
    this.isStagesLoading = true,
    this.stagesError,
    this.stages = const [],
    this.selectedStage,
    this.selectedTrack,
    this.selectedGrade,
    this.selectedSubject,
    this.isLessonsLoading = false,
    this.lessonsError,
    this.chapters = const [],
    this.semester = OutcomesMapSemester.first,
    this.generatedInput,
  });

  List<String> get availableTracks {
    if (selectedStage == null) return const [];
    final tracks = <String>{};
    for (final grade in selectedStage!.grades) {
      if (grade.track != null && grade.track!.trim().isNotEmpty) {
        tracks.add(grade.track!.trim());
      }
    }
    return tracks.toList();
  }

  bool get showGrades =>
      selectedStage != null && (availableTracks.isEmpty || selectedTrack != null);

  List<CurriculumGradeModel> get availableGrades {
    if (selectedStage == null) return const [];
    final tracks = availableTracks;
    if (tracks.isNotEmpty) {
      if (selectedTrack == null) return const [];
      return selectedStage!.grades.where((grade) => grade.track?.trim() == selectedTrack).toList();
    }
    return selectedStage!.grades;
  }

  List<CurriculumSubjectModel> get availableSubjects => selectedGrade?.subjects ?? const [];

  /// Lessons the picked semester would include, to tell the teacher before
  /// they tap «ابدأ» whether the skeleton will have anything in it.
  int get semesterLessonCount => chapters.fold(
        0,
        (sum, chapter) => sum + chapter.lessonsInSemester(semester).length,
      );

  bool get canStart =>
      selectedSubject != null && !isLessonsLoading && semesterLessonCount > 0;

  NewOutcomesMapState copyWith({
    bool? isStagesLoading,
    String? stagesError,
    bool clearStagesError = false,
    List<CurriculumStageModel>? stages,
    CurriculumStageModel? selectedStage,
    String? selectedTrack,
    bool clearTrack = false,
    CurriculumGradeModel? selectedGrade,
    bool clearGrade = false,
    CurriculumSubjectModel? selectedSubject,
    bool clearSubject = false,
    bool? isLessonsLoading,
    String? lessonsError,
    bool clearLessonsError = false,
    List<CurriculumChapterModel>? chapters,
    String? semester,
    OutcomesMapInput? generatedInput,
  }) {
    return NewOutcomesMapState(
      isStagesLoading: isStagesLoading ?? this.isStagesLoading,
      stagesError: clearStagesError ? null : (stagesError ?? this.stagesError),
      stages: stages ?? this.stages,
      selectedStage: selectedStage ?? this.selectedStage,
      selectedTrack: clearTrack ? null : (selectedTrack ?? this.selectedTrack),
      selectedGrade: clearGrade ? null : (selectedGrade ?? this.selectedGrade),
      selectedSubject: clearSubject ? null : (selectedSubject ?? this.selectedSubject),
      isLessonsLoading: isLessonsLoading ?? this.isLessonsLoading,
      lessonsError: clearLessonsError ? null : (lessonsError ?? this.lessonsError),
      chapters: chapters ?? this.chapters,
      semester: semester ?? this.semester,
      generatedInput: generatedInput,
    );
  }
}

part of 'new_reading_cubit.dart';

enum ReadingAiStatus { idle, generating, failed, rateLimited }

class NewReadingState {
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
  final String lessonSearch;
  final CurriculumLessonModel? selectedLesson;

  // Generation options.
  final ReadingLevel level;
  final ReadingLength length;
  final int questionsCount;
  final ReadingLanguage language;

  final ReadingAiStatus aiStatus;
  final String? aiErrorMessage;
  final PaymentRequiredFailure? paymentRequired;
  final ReadingComprehensionInput? generatedInput;

  const NewReadingState({
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
    this.lessonSearch = '',
    this.selectedLesson,
    this.level = ReadingLevel.medium,
    this.length = ReadingLength.medium,
    this.questionsCount = ReadingLimits.defaultGeneratedQuestions,
    this.language = ReadingLanguage.arabic,
    this.aiStatus = ReadingAiStatus.idle,
    this.aiErrorMessage,
    this.paymentRequired,
    this.generatedInput,
  });

  bool get isGeneratingAi => aiStatus == ReadingAiStatus.generating;

  bool get isEnglishSubject {
    final subject = selectedSubject?.name ?? '';
    final lower = subject.toLowerCase();
    return lower.contains('english') || subject.contains('إنجليز') || subject.contains('انجليز');
  }

  bool get canGenerate => selectedLesson != null && !isGeneratingAi && !isLessonsLoading;

  List<String> get availableTracks {
    if (selectedStage == null) return const [];
    final tracks = <String>{};
    for (final grade in selectedStage!.grades) {
      if (grade.track != null && grade.track!.trim().isNotEmpty) tracks.add(grade.track!.trim());
    }
    return tracks.toList();
  }

  bool get showGrades => selectedStage != null && (availableTracks.isEmpty || selectedTrack != null);

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

  List<CurriculumChapterModel> get filteredChapters {
    final query = lessonSearch.trim().toLowerCase();
    if (query.isEmpty) return chapters;
    final filtered = <CurriculumChapterModel>[];
    for (final chapter in chapters) {
      if (chapter.title.toLowerCase().contains(query)) {
        filtered.add(chapter);
        continue;
      }
      final matchingLessons =
          chapter.lessons.where((lesson) => lesson.title.toLowerCase().contains(query)).toList();
      if (matchingLessons.isNotEmpty) {
        filtered.add(CurriculumChapterModel(
          chapterId: chapter.chapterId,
          title: chapter.title,
          unitId: chapter.unitId,
          unitName: chapter.unitName,
          semester: chapter.semester,
          lessons: matchingLessons,
        ));
      }
    }
    return filtered;
  }

  NewReadingState copyWith({
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
    String? lessonSearch,
    CurriculumLessonModel? selectedLesson,
    bool clearSelectedLesson = false,
    ReadingLevel? level,
    ReadingLength? length,
    int? questionsCount,
    ReadingLanguage? language,
    ReadingAiStatus? aiStatus,
    String? aiErrorMessage,
    bool clearAiError = false,
    PaymentRequiredFailure? paymentRequired,
    ReadingComprehensionInput? generatedInput,
  }) {
    return NewReadingState(
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
      lessonSearch: lessonSearch ?? this.lessonSearch,
      selectedLesson: clearSelectedLesson ? null : (selectedLesson ?? this.selectedLesson),
      level: level ?? this.level,
      length: length ?? this.length,
      questionsCount: questionsCount ?? this.questionsCount,
      language: language ?? this.language,
      aiStatus: aiStatus ?? this.aiStatus,
      aiErrorMessage: clearAiError ? null : (aiErrorMessage ?? this.aiErrorMessage),
      paymentRequired: paymentRequired,
      generatedInput: generatedInput,
    );
  }
}

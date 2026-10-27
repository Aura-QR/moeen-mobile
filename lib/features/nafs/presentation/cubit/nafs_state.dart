import 'package:moean/features/nafs/data/models/nafs_models.dart';

enum NafsStep { choose, generating, review }

class NafsState {
  final NafsStep step;
  final bool isLoadingOptions;
  final String? optionsError;
  final List<NafsGradeOption> grades;
  final NafsGradeOption? selectedGrade;
  final NafsSubjectOption? selectedSubject;
  final Set<String> selectedDomainIds;
  final int questionsCount;
  final bool isRealExam;
  final String passage;
  final List<NafsDomain> domains;
  final String title;
  final bool isSaving;
  final int? savedExamId;
  final String? error;

  const NafsState({
    this.step = NafsStep.choose,
    this.isLoadingOptions = false,
    this.optionsError,
    this.grades = const [],
    this.selectedGrade,
    this.selectedSubject,
    this.selectedDomainIds = const {},
    this.questionsCount = 20,
    this.isRealExam = true,
    this.passage = '',
    this.domains = const [],
    this.title = '',
    this.isSaving = false,
    this.savedExamId,
    this.error,
  });

  List<NafsSubjectOption> get availableSubjects =>
      selectedGrade?.visibleSubjects ?? const [];

  bool get isReading => selectedSubject?.isReading == true;

  bool get canGenerate =>
      selectedGrade != null &&
      selectedSubject != null &&
      selectedDomainIds.isNotEmpty &&
      questionsCount >= 5 &&
      questionsCount <= 25;

  int get totalQuestionsCount =>
      domains.fold(0, (sum, d) => sum + d.questions.length);

  bool get allComplete =>
      domains.isNotEmpty &&
      domains.every((d) => d.name.trim().isNotEmpty && d.questions.isNotEmpty && d.questions.every((q) => q.isComplete));

  NafsState copyWith({
    NafsStep? step,
    bool? isLoadingOptions,
    String? optionsError,
    bool clearOptionsError = false,
    List<NafsGradeOption>? grades,
    NafsGradeOption? selectedGrade,
    bool clearGrade = false,
    NafsSubjectOption? selectedSubject,
    bool clearSubject = false,
    Set<String>? selectedDomainIds,
    int? questionsCount,
    bool? isRealExam,
    String? passage,
    List<NafsDomain>? domains,
    String? title,
    bool? isSaving,
    int? savedExamId,
    bool clearSavedExamId = false,
    String? error,
    bool clearError = false,
  }) =>
      NafsState(
        step: step ?? this.step,
        isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
        optionsError: clearOptionsError ? null : (optionsError ?? this.optionsError),
        grades: grades ?? this.grades,
        selectedGrade: clearGrade ? null : (selectedGrade ?? this.selectedGrade),
        selectedSubject: clearSubject ? null : (selectedSubject ?? this.selectedSubject),
        selectedDomainIds: selectedDomainIds ?? this.selectedDomainIds,
        questionsCount: questionsCount ?? this.questionsCount,
        isRealExam: isRealExam ?? this.isRealExam,
        passage: passage ?? this.passage,
        domains: domains ?? this.domains,
        title: title ?? this.title,
        isSaving: isSaving ?? this.isSaving,
        savedExamId: clearSavedExamId ? null : (savedExamId ?? this.savedExamId),
        error: clearError ? null : (error ?? this.error),
      );
}

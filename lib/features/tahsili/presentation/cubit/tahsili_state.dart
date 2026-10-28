import 'package:moean/features/tahsili/data/models/tahsili_models.dart';

enum TahsiliStep { choose, generating, review }

class TahsiliState {
  final TahsiliStep step;
  final bool isLoadingOptions;
  final String? optionsError;
  final TahsiliOptions options;
  final TahsiliSubjectOption? selectedSubject;
  final Set<String> selectedDomainIds;
  final int questionsCount;
  final List<TahsiliDomain> domains;
  final String title;
  final bool isSaving;
  final int? savedExamId;
  final String? error;
  final Map<String, String> fieldErrors;

  const TahsiliState({
    this.step = TahsiliStep.choose,
    this.isLoadingOptions = false,
    this.optionsError,
    this.options = const TahsiliOptions(),
    this.selectedSubject,
    this.selectedDomainIds = const {},
    this.questionsCount = 10,
    this.domains = const [],
    this.title = '',
    this.isSaving = false,
    this.savedExamId,
    this.error,
    this.fieldErrors = const {},
  });

  List<TahsiliSubjectOption> get availableSubjects => options.visibleSubjects;

  TahsiliLimits get effectiveLimits => selectedSubject?.limits ?? options.limits;

  bool get canGenerate =>
      selectedSubject != null &&
      selectedDomainIds.isNotEmpty &&
      questionsCount >= effectiveLimits.min &&
      questionsCount <= effectiveLimits.max;

  int get totalQuestionsCount =>
      domains.fold(0, (sum, d) => sum + d.questions.length);

  bool get allComplete =>
      domains.isNotEmpty &&
      domains.every((d) =>
          d.name.trim().isNotEmpty &&
          d.questions.isNotEmpty &&
          d.questions.every((q) => q.isComplete));

  String? fieldError(String path) => fieldErrors[path];

  bool hasFieldError(String path) => fieldErrors.containsKey(path);

  TahsiliState copyWith({
    TahsiliStep? step,
    bool? isLoadingOptions,
    String? optionsError,
    bool clearOptionsError = false,
    TahsiliOptions? options,
    TahsiliSubjectOption? selectedSubject,
    bool clearSubject = false,
    Set<String>? selectedDomainIds,
    int? questionsCount,
    List<TahsiliDomain>? domains,
    String? title,
    bool? isSaving,
    int? savedExamId,
    bool clearSavedExamId = false,
    String? error,
    bool clearError = false,
    Map<String, String>? fieldErrors,
    bool clearFieldErrors = false,
  }) =>
      TahsiliState(
        step: step ?? this.step,
        isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
        optionsError: clearOptionsError ? null : (optionsError ?? this.optionsError),
        options: options ?? this.options,
        selectedSubject: clearSubject ? null : (selectedSubject ?? this.selectedSubject),
        selectedDomainIds: selectedDomainIds ?? this.selectedDomainIds,
        questionsCount: questionsCount ?? this.questionsCount,
        domains: domains ?? this.domains,
        title: title ?? this.title,
        isSaving: isSaving ?? this.isSaving,
        savedExamId: clearSavedExamId ? null : (savedExamId ?? this.savedExamId),
        error: clearError ? null : (error ?? this.error),
        fieldErrors: clearFieldErrors ? const {} : (fieldErrors ?? this.fieldErrors),
      );
}

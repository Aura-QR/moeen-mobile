import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/nafs/data/models/nafs_models.dart';
import 'package:moean/features/nafs/data/repositories/nafs_repository.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_state.dart';

export 'package:moean/features/nafs/presentation/cubit/nafs_state.dart';

class NafsCubit extends Cubit<NafsState> {
  final NafsRepository _repository;
  final Duration pollEvery;

  NafsCubit(
    this._repository, {
    this.pollEvery = const Duration(seconds: 2),
  }) : super(const NafsState());

  static NafsCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> loadOptions() async {
    emit(state.copyWith(isLoadingOptions: true, clearOptionsError: true));
    final result = await _repository.getOptions();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoadingOptions: false, optionsError: failure.message)),
      (grades) {
        final selectedGrade = state.selectedGrade ?? grades.firstOrNull;
        final available = selectedGrade?.visibleSubjects ?? const [];
        final selectedSubject = state.selectedSubject ?? available.firstOrNull;
        final domainIds = selectedSubject?.domains.map((d) => d.id).toSet() ?? const <String>{};
        final count = selectedSubject?.realExamQuestions ?? 20;

        emit(state.copyWith(
          isLoadingOptions: false,
          grades: grades,
          selectedGrade: selectedGrade,
          selectedSubject: selectedSubject,
          selectedDomainIds: domainIds,
          questionsCount: count.clamp(5, 25),
        ));
      },
    );
  }

  void selectGrade(NafsGradeOption grade) {
    if (state.selectedGrade?.id == grade.id) return;
    final available = grade.visibleSubjects;
    final subject = available.firstOrNull;
    final domainIds = subject?.domains.map((d) => d.id).toSet() ?? const <String>{};
    final count = subject?.realExamQuestions ?? 20;

    emit(state.copyWith(
      selectedGrade: grade,
      selectedSubject: subject,
      clearSubject: subject == null,
      selectedDomainIds: domainIds,
      questionsCount: count.clamp(5, 25),
      isRealExam: true,
      clearError: true,
    ));
  }

  void selectSubject(NafsSubjectOption subject) {
    if (state.selectedSubject?.id == subject.id) return;
    final domainIds = subject.domains.map((d) => d.id).toSet();
    final count = subject.realExamQuestions;

    emit(state.copyWith(
      selectedSubject: subject,
      selectedDomainIds: domainIds,
      questionsCount: count.clamp(5, 25),
      isRealExam: true,
      clearError: true,
    ));
  }

  void toggleDomain(String domainId) {
    final updated = Set<String>.from(state.selectedDomainIds);
    if (updated.contains(domainId)) {
      updated.remove(domainId);
    } else {
      updated.add(domainId);
    }
    final allIds = state.selectedSubject?.domains.map((d) => d.id).toSet() ?? const <String>{};
    final isAllSelected = allIds.isNotEmpty && updated.containsAll(allIds);
    emit(state.copyWith(
      selectedDomainIds: updated,
      isRealExam: isAllSelected && state.questionsCount == (state.selectedSubject?.realExamQuestions ?? 20),
      clearError: true,
    ));
  }

  void toggleSelectAllDomains() {
    final allIds = state.selectedSubject?.domains.map((d) => d.id).toSet() ?? const <String>{};
    if (state.selectedDomainIds.length == allIds.length) {
      emit(state.copyWith(selectedDomainIds: const {}, isRealExam: false, clearError: true));
    } else {
      emit(state.copyWith(
        selectedDomainIds: allIds,
        isRealExam: state.questionsCount == (state.selectedSubject?.realExamQuestions ?? 20),
        clearError: true,
      ));
    }
  }

  void setQuestionsCount(int count) {
    final clamped = count.clamp(5, 25);
    final isReal = state.selectedSubject != null &&
        clamped == state.selectedSubject!.realExamQuestions &&
        state.selectedDomainIds.length == state.selectedSubject!.domains.length;
    emit(state.copyWith(
      questionsCount: clamped,
      isRealExam: isReal,
      clearError: true,
    ));
  }

  void toggleRealExam(bool value) {
    if (value) {
      final subject = state.selectedSubject;
      final count = subject?.realExamQuestions ?? 20;
      final allIds = subject?.domains.map((d) => d.id).toSet() ?? const <String>{};
      emit(state.copyWith(
        isRealExam: true,
        questionsCount: count.clamp(5, 25),
        selectedDomainIds: allIds,
        clearError: true,
      ));
    } else {
      emit(state.copyWith(isRealExam: false));
    }
  }

  void setTitle(String value) => emit(state.copyWith(title: value));

  void setPassage(String value) => emit(state.copyWith(passage: value));

  Future<void> generate() async {
    final grade = state.selectedGrade;
    final subject = state.selectedSubject;
    if (grade == null || subject == null) return;
    if (state.selectedDomainIds.isEmpty) {
      emit(state.copyWith(error: 'nafs_no_domains_selected'));
      return;
    }

    emit(state.copyWith(step: NafsStep.generating, clearError: true));

    final selectedDomainKeys = state.selectedDomainIds.toList();

    final started = await _repository.generate(
      grade: grade.id,
      subject: subject.id,
      subjectIds: subject.subjectIds,
      domainIds: selectedDomainKeys,
      domains: selectedDomainKeys,
      questionsCount: state.questionsCount,
      isRealExam: state.isRealExam,
    );

    if (isClosed) return;

    var job = started.fold(
      (f) {
        emit(state.copyWith(step: NafsStep.choose, error: f.message));
        return null;
      },
      (j) => j,
    );

    for (var i = 0; job != null && job.isPending && i < 100; i++) {
      final current = job;
      await Future<void>.delayed(pollEvery);
      if (isClosed) return;
      final polled = await _repository.getJob(current.id);
      job = polled.fold((_) => current, (j) => j);
    }

    if (job == null) return;

    if (!job.isDone || job.domains.isEmpty) {
      emit(state.copyWith(step: NafsStep.choose, error: job.error ?? 'nafs_failed'));
      return;
    }

    final gradeLabel = grade.name;
    final subjectLabel = subject.name;
    final defaultTitle = 'اختبار تدريبي بأسلوب نافس — $subjectLabel — $gradeLabel';

    emit(state.copyWith(
      step: NafsStep.review,
      domains: job.domains,
      passage: job.passage ?? '',
      title: defaultTitle,
    ));
  }

  void renameDomain(int index, String name) => _modifyDomain(index, (d) => d.copyWith(name: name));

  void removeDomain(int index) =>
      emit(state.copyWith(domains: [...state.domains]..removeAt(index)));

  void updateQuestion(int domainIndex, int questionIndex, NafsQuestion q) =>
      _modifyDomain(domainIndex, (d) => d.copyWith(questions: [...d.questions]..[questionIndex] = q));

  void removeQuestion(int domainIndex, int questionIndex) =>
      _modifyDomain(domainIndex, (d) => d.copyWith(questions: [...d.questions]..removeAt(questionIndex)));

  void addQuestion(int domainIndex) => _modifyDomain(
        domainIndex,
        (d) => d.copyWith(
          questions: [
            ...d.questions,
            const NafsQuestion(
              text: '',
              options: ['', '', '', ''],
              answer: '',
            ),
          ],
        ),
      );

  void _modifyDomain(int i, NafsDomain Function(NafsDomain) fn) {
    final list = [...state.domains];
    list[i] = fn(list[i]);
    emit(state.copyWith(domains: list));
  }

  void restart() => emit(state.copyWith(step: NafsStep.choose, domains: const []));

  Future<void> save() async {
    final grade = state.selectedGrade;
    final subject = state.selectedSubject;
    if (grade == null || subject == null || state.isSaving) return;

    final kept = state.domains.where((d) => d.name.trim().isNotEmpty && d.questions.isNotEmpty).toList();
    if (kept.isEmpty) {
      emit(state.copyWith(error: 'nafs_no_questions'));
      return;
    }

    if (!state.allComplete) {
      emit(state.copyWith(error: 'nafs_missing_answers'));
      return;
    }

    emit(state.copyWith(isSaving: true, clearError: true));

    final result = await _repository.save(
      grade: grade.id,
      subject: subject.id,
      subjectIds: subject.subjectIds,
      title: state.title.trim().isEmpty ? 'اختبار تدريبي بأسلوب نافس' : state.title.trim(),
      passage: state.passage,
      domains: kept,
    );

    if (isClosed) return;

    result.fold(
      (f) => emit(state.copyWith(isSaving: false, error: f.message)),
      (id) => emit(state.copyWith(isSaving: false, savedExamId: id)),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
}

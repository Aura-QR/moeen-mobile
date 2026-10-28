import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/tahsili/data/models/tahsili_models.dart';
import 'package:moean/features/tahsili/data/repositories/tahsili_repository.dart';
import 'package:moean/features/tahsili/presentation/cubit/tahsili_state.dart';

export 'package:moean/features/tahsili/presentation/cubit/tahsili_state.dart';

class TahsiliCubit extends Cubit<TahsiliState> {
  final TahsiliRepository _repository;
  final Duration pollEvery;

  TahsiliCubit(
    this._repository, {
    this.pollEvery = const Duration(seconds: 2),
  }) : super(const TahsiliState());

  static TahsiliCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> loadOptions() async {
    emit(state.copyWith(isLoadingOptions: true, clearOptionsError: true));
    final result = await _repository.getOptions();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoadingOptions: false, optionsError: failure.message)),
      (options) {
        final available = options.visibleSubjects;
        final selectedSubject = state.selectedSubject ?? available.firstOrNull;
        final domainIds = selectedSubject?.domains.map((d) => d.id).toSet() ?? const <String>{};
        final limits = selectedSubject?.limits ?? options.limits;

        emit(state.copyWith(
          isLoadingOptions: false,
          options: options,
          selectedSubject: selectedSubject,
          selectedDomainIds: domainIds,
          questionsCount: limits.defaultCount.clamp(limits.min, limits.max),
        ));
      },
    );
  }

  void selectSubject(TahsiliSubjectOption subject) {
    if (state.selectedSubject?.id == subject.id) return;
    final domainIds = subject.domains.map((d) => d.id).toSet();
    final limits = subject.limits ?? state.options.limits;

    emit(state.copyWith(
      selectedSubject: subject,
      selectedDomainIds: domainIds,
      questionsCount: limits.defaultCount.clamp(limits.min, limits.max),
      clearError: true,
      clearFieldErrors: true,
    ));
  }

  void toggleDomain(String domainId) {
    final updated = Set<String>.from(state.selectedDomainIds);
    if (updated.contains(domainId)) {
      updated.remove(domainId);
    } else {
      updated.add(domainId);
    }
    emit(state.copyWith(
      selectedDomainIds: updated,
      clearError: true,
      clearFieldErrors: true,
    ));
  }

  void toggleSelectAllDomains() {
    final allIds = state.selectedSubject?.domains.map((d) => d.id).toSet() ?? const <String>{};
    if (state.selectedDomainIds.length == allIds.length) {
      emit(state.copyWith(selectedDomainIds: const {}, clearError: true));
    } else {
      emit(state.copyWith(selectedDomainIds: allIds, clearError: true));
    }
  }

  void setQuestionsCount(int count) {
    final limits = state.effectiveLimits;
    final clamped = count.clamp(limits.min, limits.max);
    emit(state.copyWith(questionsCount: clamped, clearError: true));
  }

  void setTitle(String value) => emit(state.copyWith(title: value, clearFieldErrors: true));

  Future<void> generate() async {
    final subject = state.selectedSubject;
    if (subject == null) {
      emit(state.copyWith(error: 'tahsili_no_subjects'));
      return;
    }
    if (state.selectedDomainIds.isEmpty) {
      emit(state.copyWith(error: 'tahsili_no_domains_selected'));
      return;
    }

    emit(state.copyWith(step: TahsiliStep.generating, clearError: true, clearFieldErrors: true));

    final selectedDomainKeys = state.selectedDomainIds.toList();
    final started = await _repository.generate(
      subject: subject.id,
      domainIds: selectedDomainKeys,
      questionsCount: state.questionsCount,
    );

    if (isClosed) return;

    var job = started.fold(
      (failure) {
        emit(state.copyWith(step: TahsiliStep.choose, error: failure.message));
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
      emit(state.copyWith(step: TahsiliStep.choose, error: job.error ?? 'tahsili_failed'));
      return;
    }

    final defaultTitle = 'اختبار تدريبي بأسلوب التحصيلي — ${subject.name}';

    emit(state.copyWith(
      step: TahsiliStep.review,
      domains: job.domains,
      title: defaultTitle,
      clearFieldErrors: true,
    ));
  }

  void renameDomain(int index, String name) => _modifyDomain(index, (d) => d.copyWith(name: name));

  void removeDomain(int index) =>
      emit(state.copyWith(domains: [...state.domains]..removeAt(index), clearFieldErrors: true));

  void updateQuestion(int domainIndex, int questionIndex, TahsiliQuestion q) =>
      _modifyDomain(domainIndex, (d) => d.copyWith(questions: [...d.questions]..[questionIndex] = q));

  void removeQuestion(int domainIndex, int questionIndex) =>
      _modifyDomain(domainIndex, (d) => d.copyWith(questions: [...d.questions]..removeAt(questionIndex)));

  void addQuestion(int domainIndex) => _modifyDomain(
        domainIndex,
        (d) => d.copyWith(
          questions: [
            ...d.questions,
            const TahsiliQuestion(
              text: '',
              options: ['', '', '', ''],
              answer: '',
            ),
          ],
        ),
      );

  void _modifyDomain(int i, TahsiliDomain Function(TahsiliDomain) fn) {
    final list = [...state.domains];
    list[i] = fn(list[i]);
    emit(state.copyWith(domains: list, clearFieldErrors: true));
  }

  void restart() => emit(state.copyWith(
        step: TahsiliStep.choose,
        domains: const [],
        clearFieldErrors: true,
      ));

  Future<void> save() async {
    final subject = state.selectedSubject;
    if (subject == null || state.isSaving) return;

    final kept = state.domains.where((d) => d.name.trim().isNotEmpty && d.questions.isNotEmpty).toList();
    if (kept.isEmpty) {
      emit(state.copyWith(error: 'tahsili_no_questions'));
      return;
    }

    if (!state.allComplete) {
      emit(state.copyWith(error: 'tahsili_missing_answers'));
      return;
    }

    emit(state.copyWith(isSaving: true, clearError: true, clearFieldErrors: true));

    final result = await _repository.save(
      subject: subject.id,
      title: state.title.trim().isEmpty ? 'اختبار تدريبي بأسلوب التحصيلي — ${subject.name}' : state.title.trim(),
      domains: kept,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          final mappedErrors = <String, String>{};
          for (final entry in failure.errors.entries) {
            final val = entry.value;
            mappedErrors[entry.key] = val is List ? val.join(' ') : '$val';
          }
          emit(state.copyWith(
            isSaving: false,
            error: failure.message.isNotEmpty ? failure.message : 'tahsili_missing_answers',
            fieldErrors: mappedErrors,
          ));
        } else {
          emit(state.copyWith(isSaving: false, error: failure.message));
        }
      },
      (id) => emit(state.copyWith(isSaving: false, savedExamId: id)),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
}

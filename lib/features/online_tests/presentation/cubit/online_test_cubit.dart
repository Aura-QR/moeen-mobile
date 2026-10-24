import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/data/repositories/online_tests_repository.dart';

class OnlineTestScreenState {
  final OnlineTest? test;
  final OnlineTestResults? results;
  final bool isLoading;
  final bool isBusy;

  /// AI-suggested marks: running, and how many answers were sent so far.
  final bool aiRunning;
  final int aiDone;

  /// A one-off message (translation key or API text) for a snack bar.
  final String? message;
  final bool messageIsError;
  final String? loadError;

  /// One-off navigation signals.
  final int? analysisDocumentId;
  final bool deleted;

  const OnlineTestScreenState({
    this.test,
    this.results,
    this.isLoading = true,
    this.isBusy = false,
    this.aiRunning = false,
    this.aiDone = 0,
    this.message,
    this.messageIsError = false,
    this.loadError,
    this.analysisDocumentId,
    this.deleted = false,
  });

  OnlineTestScreenState copyWith({
    OnlineTest? test,
    OnlineTestResults? results,
    bool? isLoading,
    bool? isBusy,
    bool? aiRunning,
    int? aiDone,
    String? message,
    bool messageIsError = false,
    bool clearMessage = false,
    String? loadError,
    int? analysisDocumentId,
    bool clearAnalysis = false,
    bool? deleted,
  }) =>
      OnlineTestScreenState(
        test: test ?? this.test,
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        isBusy: isBusy ?? this.isBusy,
        aiRunning: aiRunning ?? this.aiRunning,
        aiDone: aiDone ?? this.aiDone,
        message: clearMessage ? null : message ?? this.message,
        messageIsError: message != null ? messageIsError : this.messageIsError,
        loadError: loadError,
        analysisDocumentId: clearAnalysis ? null : analysisDocumentId ?? this.analysisDocumentId,
        deleted: deleted ?? this.deleted,
      );
}

/// One online test: links and QR per class, results, review, AI-suggested marks and «تحليل النتائج».
class OnlineTestCubit extends Cubit<OnlineTestScreenState> {
  final int testId;
  final OnlineTestsRepository _repository;
  final DocumentsRepository _documents;
  final Duration pollEvery;

  OnlineTestCubit({
    required this.testId,
    required OnlineTestsRepository repository,
    required DocumentsRepository documents,
    this.pollEvery = const Duration(seconds: 3),
  })  : _repository = repository,
        _documents = documents,
        super(const OnlineTestScreenState());

  static OnlineTestCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> load() async {
    final result = await _repository.getTest(testId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, loadError: failure.message)),
      (test) => emit(state.copyWith(isLoading: false, test: test)),
    );
    await refreshResults();
  }

  Future<void> refreshResults() async {
    final result = await _repository.getResults(testId);
    if (isClosed) return;
    result.fold((_) {}, (results) => emit(state.copyWith(results: results)));
  }

  Future<void> toggleOpen() => _update(() => _repository.setOpen(testId, !(state.test?.isOpen ?? true)));

  Future<void> addGroup(String name) => _update(() => _repository.addGroup(testId, name.trim()));

  Future<void> _update(Future<dynamic> Function() call) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true, clearMessage: true));
    final result = await call();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isBusy: false, message: failure.message, messageIsError: true)),
      (test) => emit(state.copyWith(isBusy: false, test: test as OnlineTest)),
    );
  }

  Future<void> delete() async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    final result = await _repository.delete(testId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isBusy: false, message: failure.message, messageIsError: true)),
      (_) => emit(state.copyWith(isBusy: false, deleted: true)),
    );
  }

  /// Sends the waiting answers batch by batch until none is left.
  Future<void> suggestMarks() async {
    if (state.aiRunning) return;
    emit(state.copyWith(aiRunning: true, aiDone: 0, clearMessage: true));
    String? error;
    for (var round = 0; round < 20; round++) {
      final started = await _repository.startAiGrading(testId);
      if (isClosed) return;
      final job = started.fold((f) {
        error = f.message;
        return null;
      }, (j) => j);
      if (job == null) break;
      final finished = await _wait(job);
      if (isClosed) return;
      if (finished == null || finished.isFailed) {
        error = finished?.error ?? 'online_tests_ai_failed';
        break;
      }
      emit(state.copyWith(aiDone: state.aiDone + job.queued));
      await refreshResults();
      if ((job.remaining ?? 0) == 0) break;
    }
    if (isClosed) return;
    await refreshResults();
    // A 422 «لا توجد إجابات تنتظر التصحيح» after a batch just means everything is suggested.
    final nothingLeft = error != null && error!.contains('لا توجد إجابات');
    emit(state.copyWith(
      aiRunning: false,
      message: error == null || nothingLeft ? 'online_tests_ai_done' : error,
      messageIsError: error != null && !nothingLeft,
    ));
  }

  Future<AiGradingJob?> _wait(AiGradingJob job) async {
    var current = job;
    for (var i = 0; current.isPending && i < 100; i++) {
      await Future<void>.delayed(pollEvery);
      if (isClosed) return null;
      final polled = await _repository.getAiJob(job.id);
      final next = polled.fold((_) => null, (j) => j);
      if (next != null) current = next;
    }
    return current;
  }

  Future<void> acceptSuggestions() async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    final result = await _repository.acceptAiGrading(testId);
    if (isClosed) return;
    await refreshResults();
    result.fold(
      (failure) => emit(state.copyWith(isBusy: false, message: failure.message, messageIsError: true)),
      (count) => emit(state.copyWith(isBusy: false, message: 'online_tests_ai_accepted')),
    );
  }

  /// Saves the scores as a «تحليل نتائج الطلاب» document; the screen opens it.
  Future<void> toAnalysis() async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    final input = await _repository.gradeAnalysisInput(testId);
    if (isClosed) return;
    final data = input.fold((f) {
      emit(state.copyWith(isBusy: false, message: f.message, messageIsError: true));
      return null;
    }, (d) => d);
    if (data == null) return;
    if ((data.input['classes'] as List?)?.isEmpty ?? true) {
      emit(state.copyWith(isBusy: false, message: 'online_tests_no_submissions', messageIsError: true));
      return;
    }
    final doc = await _documents.createDocument(type: 'grade_analysis', input: data.input, status: 'draft');
    if (isClosed) return;
    doc.fold(
      (f) => emit(state.copyWith(isBusy: false, message: f.message, messageIsError: true)),
      (d) => emit(state.copyWith(isBusy: false, analysisDocumentId: d.id)),
    );
  }

  void clearMessage() => emit(state.copyWith(clearMessage: true));
  void clearAnalysis() => emit(state.copyWith(clearAnalysis: true));
}

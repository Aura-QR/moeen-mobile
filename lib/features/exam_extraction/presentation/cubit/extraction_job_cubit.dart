import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_page_model.dart';
import 'package:moean/features/exam_extraction/data/repositories/exam_extraction_repository.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_job_state.dart';

class ExtractionJobCubit extends Cubit<ExtractionJobState> {
  final ExamExtractionRepository _repository;
  final Duration _pollInterval;
  final int _maxAttempts;

  Timer? _timer;
  List<ExtractionPageModel>? _lastPages;
  int _lastCount = 10;
  String? _lastNotes;

  ExtractionJobCubit({
    required ExamExtractionRepository repository,
    Duration pollInterval = const Duration(seconds: 3),
    int maxAttempts = 60,
  })  : _repository = repository,
        _pollInterval = pollInterval,
        _maxAttempts = maxAttempts,
        super(const ExtractionJobState());

  static ExtractionJobCubit get(BuildContext context) =>
      BlocProvider.of(context);

  void start({
    required List<ExtractionPageModel> pages,
    required int count,
    String? notes,
  }) {
    _lastPages = pages;
    _lastCount = count;
    _lastNotes = notes;

    _timer?.cancel();
    emit(const ExtractionJobState(status: ExtractionJobStatus.starting));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) {
        _timer?.cancel();
        return;
      }
      emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
    });

    _executeStart(pages, count, notes);
  }

  Future<void> _executeStart(
    List<ExtractionPageModel> pages,
    int count,
    String? notes,
  ) async {
    final result = await _repository.start(
      pages: pages,
      count: count,
      notes: notes,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        _timer?.cancel();
        if (failure is PaymentRequiredFailure) {
          emit(state.copyWith(
            status: ExtractionJobStatus.failed,
            paymentRequired: true,
            error: failure.message,
          ));
        } else {
          emit(state.copyWith(
            status: ExtractionJobStatus.failed,
            error: failure.message,
          ));
        }
      },
      (initialJob) {
        if (initialJob.isDone) {
          _timer?.cancel();
          if (initialJob.questions.isEmpty) {
            emit(state.copyWith(
              status: ExtractionJobStatus.failed,
              error: 'exam_extract_no_questions',
            ));
          } else {
            emit(state.copyWith(
              status: ExtractionJobStatus.done,
              job: initialJob,
            ));
          }
        } else if (initialJob.isFailed) {
          _timer?.cancel();
          emit(state.copyWith(
            status: ExtractionJobStatus.failed,
            error: initialJob.error ?? 'generic_error',
          ));
        } else {
          emit(state.copyWith(
            status: ExtractionJobStatus.polling,
            job: initialJob,
          ));
          _poll(initialJob.id);
        }
      },
    );
  }

  Future<void> _poll(int jobId) async {
    int attempts = 0;

    while (attempts < _maxAttempts) {
      if (isClosed) return;

      if (_pollInterval > Duration.zero) {
        await Future.delayed(_pollInterval);
      }
      if (isClosed) return;

      attempts++;
      final pollResult = await _repository.getJob(jobId);
      if (isClosed) return;

      bool stop = false;
      pollResult.fold(
        (failure) {
          _timer?.cancel();
          if (failure is PaymentRequiredFailure) {
            emit(state.copyWith(
              status: ExtractionJobStatus.failed,
              paymentRequired: true,
              error: failure.message,
            ));
          } else {
            emit(state.copyWith(
              status: ExtractionJobStatus.failed,
              error: failure.message,
            ));
          }
          stop = true;
        },
        (job) {
          if (job.isDone) {
            _timer?.cancel();
            if (job.questions.isEmpty) {
              emit(state.copyWith(
                status: ExtractionJobStatus.failed,
                error: 'exam_extract_no_questions',
              ));
            } else {
              emit(state.copyWith(
                status: ExtractionJobStatus.done,
                job: job,
              ));
            }
            stop = true;
          } else if (job.isFailed) {
            _timer?.cancel();
            emit(state.copyWith(
              status: ExtractionJobStatus.failed,
              error: job.error ?? 'generic_error',
            ));
            stop = true;
          } else {
            emit(state.copyWith(
              status: ExtractionJobStatus.polling,
              job: job,
            ));
          }
        },
      );

      if (stop) return;
    }

    if (!isClosed) {
      _timer?.cancel();
      emit(state.copyWith(
        status: ExtractionJobStatus.timedOut,
        error: 'exam_extract_timeout',
      ));
    }
  }

  void retry() {
    if (_lastPages != null && _lastPages!.isNotEmpty) {
      start(pages: _lastPages!, count: _lastCount, notes: _lastNotes);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

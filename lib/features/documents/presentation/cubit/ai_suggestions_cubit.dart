import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/repositories/ai_jobs_repository.dart';

part 'ai_suggestions_state.dart';

/// «اقترح من الدرس»: asks for suggestions for the picked lessons and waits
/// for them. The form adds [AiSuggestionsState.result] to its sections.
class AiSuggestionsCubit extends Cubit<AiSuggestionsState> {
  static AiSuggestionsCubit get(BuildContext context) => BlocProvider.of(context);

  AiSuggestionsCubit({
    required this.kind,
    required AiJobsRepository repository,
    Duration pollInterval = const Duration(seconds: 2),
    int maxPollAttempts = 30,
  })  : _repo = repository,
        _pollInterval = pollInterval,
        _maxPollAttempts = maxPollAttempts,
        super(const AiSuggestionsState());

  /// An [AiJobKinds] value.
  final String kind;
  final AiJobsRepository _repo;
  final Duration _pollInterval;

  /// 30 × 2 s = the 60 s the API doc allows.
  final int _maxPollAttempts;

  /// Also the retry: the same request again.
  Future<void> suggest(List<int> lessonIds) async {
    if (state.isLoading || lessonIds.isEmpty) return;
    emit(const AiSuggestionsState(status: AiSuggestionsStatus.loading));
    final result = await _waitForJob(lessonIds);
    if (isClosed) return;
    result.fold(
      (failure) => emit(failure is PaymentRequiredFailure
          ? AiSuggestionsState(paymentRequired: failure)
          : AiSuggestionsState(status: AiSuggestionsStatus.failed, errorMessage: failure.message)),
      (job) => emit(AiSuggestionsState(status: AiSuggestionsStatus.done, result: job.result)),
    );
  }

  /// `200` is already done (cached); `202` is polled until done or failed.
  Future<Either<Failure, AiJobModel>> _waitForJob(List<int> lessonIds) async {
    final started = await _repo.start(kind, lessonIds);
    return started.fold(Left.new, (first) async {
      var job = first;
      for (var attempt = 0; job.isPending; attempt++) {
        if (attempt >= _maxPollAttempts || isClosed) return const Left(ServerFailure('ai_suggestions_timeout'));
        await Future<void>.delayed(_pollInterval);
        final next = await _repo.getJob(job.id);
        final failure = next.fold<Failure?>((failure) => failure, (polled) {
          job = polled;
          return null;
        });
        if (failure != null) return Left(failure);
      }
      if (job.isFailed) return Left(ServerFailure(job.error ?? 'ai_suggestions_failed'));
      return Right(job);
    });
  }
}

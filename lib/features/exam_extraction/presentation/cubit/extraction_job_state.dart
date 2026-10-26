import 'package:equatable/equatable.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_job_model.dart';

enum ExtractionJobStatus { starting, polling, done, failed, timedOut }

class ExtractionJobState extends Equatable {
  final ExtractionJobStatus status;
  final ExtractionJobModel? job;
  final int elapsedSeconds;
  final String? error;
  final bool paymentRequired;

  const ExtractionJobState({
    this.status = ExtractionJobStatus.starting,
    this.job,
    this.elapsedSeconds = 0,
    this.error,
    this.paymentRequired = false,
  });

  String get progressMessageKey {
    if (elapsedSeconds <= 10) {
      return 'exam_extract_progress_upload';
    } else if (elapsedSeconds <= 40) {
      return 'exam_extract_progress_reading';
    } else {
      return 'exam_extract_progress_long';
    }
  }

  ExtractionJobState copyWith({
    ExtractionJobStatus? status,
    ExtractionJobModel? job,
    int? elapsedSeconds,
    String? error,
    bool? paymentRequired,
    bool clearError = false,
  }) {
    return ExtractionJobState(
      status: status ?? this.status,
      job: job ?? this.job,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      error: clearError ? null : (error ?? this.error),
      paymentRequired: paymentRequired ?? this.paymentRequired,
    );
  }

  @override
  List<Object?> get props => [
        status,
        job,
        elapsedSeconds,
        error,
        paymentRequired,
      ];
}

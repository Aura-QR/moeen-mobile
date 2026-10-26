part of 'performance_cubit.dart';

enum PerformanceStatus { loading, success, failure }

class PerformanceState {
  final PerformanceStatus status;
  final PerformanceModel? performance;
  final String? errorMessage;

  /// The item whose rating is being saved.
  final int? ratingItemId;
  final bool isSavingCv;

  /// One-shot, cleared by [copyWith] unless passed.
  final UiFeedback? feedback;

  const PerformanceState({
    this.status = PerformanceStatus.loading,
    this.performance,
    this.errorMessage,
    this.ratingItemId,
    this.isSavingCv = false,
    this.feedback,
  });

  PerformanceState copyWith({
    PerformanceStatus? status,
    PerformanceModel? performance,
    String? errorMessage,
    int? ratingItemId,
    bool clearRatingItem = false,
    bool? isSavingCv,
    UiFeedback? feedback,
  }) {
    return PerformanceState(
      status: status ?? this.status,
      performance: performance ?? this.performance,
      errorMessage: errorMessage ?? this.errorMessage,
      ratingItemId: clearRatingItem ? null : (ratingItemId ?? this.ratingItemId),
      isSavingCv: isSavingCv ?? this.isSavingCv,
      feedback: feedback,
    );
  }
}

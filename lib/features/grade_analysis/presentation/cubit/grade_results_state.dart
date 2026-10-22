part of 'grade_results_cubit.dart';

enum GradeResultsStatus { waiting, loading, success, failure }

class GradeResultsState {
  final GradeResultsStatus status;

  /// While loading, the previous numbers, shown until the new ones land.
  final GradeAnalysisResult? result;

  /// While [GradeResultsStatus.waiting]: what the form still needs, as a translation key.
  final String? issue;
  final String? errorMessage;

  const GradeResultsState({this.status = GradeResultsStatus.waiting, this.result, this.issue, this.errorMessage});

  /// Statistics only, for «اقترح توصيات»; null until there are numbers.
  Map<String, dynamic>? get aiInput =>
      status == GradeResultsStatus.success && result!.aiInput.isNotEmpty ? result!.aiInput : null;
}

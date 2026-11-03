part of 'lab_experiment_cubit.dart';

enum LabWebViewStatus { loading, ready, error }

@immutable
class LabExperimentState {
  final LabWebViewStatus webViewStatus;
  final LabExperimentModel? experiment;
  final bool isLoadingDetails;
  final bool isReporting;
  final bool reportSuccess;
  final String? reportError;
  final UiFeedback? feedback;

  const LabExperimentState({
    this.webViewStatus = LabWebViewStatus.loading,
    this.experiment,
    this.isLoadingDetails = false,
    this.isReporting = false,
    this.reportSuccess = false,
    this.reportError,
    this.feedback,
  });

  List<LabLinkedLessonModel> get linkedLessons =>
      experiment?.lessons ?? const [];

  LabExperimentState copyWith({
    LabWebViewStatus? webViewStatus,
    LabExperimentModel? experiment,
    bool? isLoadingDetails,
    bool? isReporting,
    bool? reportSuccess,
    String? reportError,
    UiFeedback? feedback,
  }) {
    return LabExperimentState(
      webViewStatus: webViewStatus ?? this.webViewStatus,
      experiment: experiment ?? this.experiment,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      isReporting: isReporting ?? this.isReporting,
      reportSuccess: reportSuccess ?? this.reportSuccess,
      reportError: reportError,
      feedback: feedback,
    );
  }
}

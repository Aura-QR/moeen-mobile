part of 'lab_experiment_cubit.dart';

enum LabWebViewStatus { loading, ready, error }

@immutable
class LabExperimentState {
  final LabWebViewStatus webViewStatus;
  final bool isReporting;
  final bool reportSuccess;
  final String? reportError;
  final UiFeedback? feedback;

  const LabExperimentState({
    this.webViewStatus = LabWebViewStatus.loading,
    this.isReporting = false,
    this.reportSuccess = false,
    this.reportError,
    this.feedback,
  });

  LabExperimentState copyWith({
    LabWebViewStatus? webViewStatus,
    bool? isReporting,
    bool? reportSuccess,
    String? reportError,
    UiFeedback? feedback,
  }) {
    return LabExperimentState(
      webViewStatus: webViewStatus ?? this.webViewStatus,
      isReporting: isReporting ?? this.isReporting,
      reportSuccess: reportSuccess ?? this.reportSuccess,
      reportError: reportError,
      feedback: feedback,
    );
  }
}

part of 'admin_lab_cubit.dart';

@immutable
class AdminLabState {
  final int currentTab; // 0: experiments, 1: reports, 2: requests
  final List<AdminLabExperimentModel> experiments;
  final List<AdminLabMistakeReportModel> reports;
  final List<AdminLabRequestModel> requests;
  final bool isLoadingExperiments;
  final bool isLoadingReports;
  final bool isLoadingRequests;
  final bool isActionInProgress;
  final String? experimentFilter; // null, 'community', 'hidden', 'reports'
  final String? reportFilter; // null, 'open', 'done'
  final String? requestFilter; // null, 'open', 'done'
  final String? errorMessage;
  final UiFeedback? feedback;

  const AdminLabState({
    this.currentTab = 0,
    this.experiments = const [],
    this.reports = const [],
    this.requests = const [],
    this.isLoadingExperiments = false,
    this.isLoadingReports = false,
    this.isLoadingRequests = false,
    this.isActionInProgress = false,
    this.experimentFilter,
    this.reportFilter,
    this.requestFilter,
    this.errorMessage,
    this.feedback,
  });

  AdminLabState copyWith({
    int? currentTab,
    List<AdminLabExperimentModel>? experiments,
    List<AdminLabMistakeReportModel>? reports,
    List<AdminLabRequestModel>? requests,
    bool? isLoadingExperiments,
    bool? isLoadingReports,
    bool? isLoadingRequests,
    bool? isActionInProgress,
    String? experimentFilter,
    bool clearExperimentFilter = false,
    String? reportFilter,
    bool clearReportFilter = false,
    String? requestFilter,
    bool clearRequestFilter = false,
    String? errorMessage,
    UiFeedback? feedback,
  }) {
    return AdminLabState(
      currentTab: currentTab ?? this.currentTab,
      experiments: experiments ?? this.experiments,
      reports: reports ?? this.reports,
      requests: requests ?? this.requests,
      isLoadingExperiments:
          isLoadingExperiments ?? this.isLoadingExperiments,
      isLoadingReports: isLoadingReports ?? this.isLoadingReports,
      isLoadingRequests: isLoadingRequests ?? this.isLoadingRequests,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      experimentFilter: clearExperimentFilter
          ? null
          : (experimentFilter ?? this.experimentFilter),
      reportFilter:
          clearReportFilter ? null : (reportFilter ?? this.reportFilter),
      requestFilter:
          clearRequestFilter ? null : (requestFilter ?? this.requestFilter),
      errorMessage: errorMessage,
      feedback: feedback,
    );
  }
}

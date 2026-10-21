part of 'achievement_report_cubit.dart';

enum AchievementReportStatus { loading, success, failure }

class AchievementReportState {
  final AchievementPeriod period;

  /// Any day inside the period being shown.
  final DateTime date;
  final AchievementReportStatus status;
  final AchievementReportModel? report;
  final String? errorMessage;

  /// False when the period already reaches today; the future has no data.
  final bool canGoNext;
  final bool isExporting;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final Uint8List? pdfBytes;
  final String? feedback;

  const AchievementReportState({
    required this.period,
    required this.date,
    this.status = AchievementReportStatus.loading,
    this.report,
    this.errorMessage,
    this.canGoNext = false,
    this.isExporting = false,
    this.pdfBytes,
    this.feedback,
  });

  AchievementReportState copyWith({
    AchievementPeriod? period,
    DateTime? date,
    AchievementReportStatus? status,
    AchievementReportModel? report,
    String? errorMessage,
    bool? canGoNext,
    bool? isExporting,
    Uint8List? pdfBytes,
    String? feedback,
  }) {
    return AchievementReportState(
      period: period ?? this.period,
      date: date ?? this.date,
      status: status ?? this.status,
      report: report ?? this.report,
      errorMessage: errorMessage ?? this.errorMessage,
      canGoNext: canGoNext ?? this.canGoNext,
      isExporting: isExporting ?? this.isExporting,
      pdfBytes: pdfBytes,
      feedback: feedback,
    );
  }
}

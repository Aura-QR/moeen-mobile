part of 'performance_export_cubit.dart';

class PerformanceExportState {
  final bool includeRatings;
  final DocumentTheme theme;
  final bool isExporting;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final int? documentId;
  final String? errorMessage;

  const PerformanceExportState({
    this.includeRatings = true,
    this.theme = DocumentTheme.teal,
    this.isExporting = false,
    this.documentId,
    this.errorMessage,
  });

  PerformanceExportState copyWith({
    bool? includeRatings,
    DocumentTheme? theme,
    bool? isExporting,
    int? documentId,
    String? errorMessage,
  }) {
    return PerformanceExportState(
      includeRatings: includeRatings ?? this.includeRatings,
      theme: theme ?? this.theme,
      isExporting: isExporting ?? this.isExporting,
      documentId: documentId,
      errorMessage: errorMessage,
    );
  }
}

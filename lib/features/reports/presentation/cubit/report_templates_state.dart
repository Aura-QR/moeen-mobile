part of 'report_templates_cubit.dart';

enum ReportTemplatesStatus { loading, success, failure }

class ReportTemplatesState {
  final ReportTemplatesStatus status;
  final ReportCatalogueModel? catalogue;
  final List<DocumentModel> saved;
  final String? errorMessage;

  const ReportTemplatesState({
    this.status = ReportTemplatesStatus.loading,
    this.catalogue,
    this.saved = const [],
    this.errorMessage,
  });

  ReportTemplatesState copyWith({
    ReportTemplatesStatus? status,
    ReportCatalogueModel? catalogue,
    List<DocumentModel>? saved,
    String? errorMessage,
  }) {
    return ReportTemplatesState(
      status: status ?? this.status,
      catalogue: catalogue ?? this.catalogue,
      saved: saved ?? this.saved,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

part of 'portfolio_editor_cubit.dart';

enum PortfolioEditorStatus { loading, success, failure }

class PortfolioEditorState {
  final PortfolioEditorStatus status;
  final PortfolioModel? portfolio;
  final PortfolioRolesModel? roles;
  final String? errorMessage;
  final bool isSaving;
  final bool isSharing;
  final bool isExporting;

  /// The item an upload is running for, with progress from 0 to 1.
  final int? uploadingItemId;
  final double uploadProgress;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final UiFeedback? feedback;
  final Uint8List? pdfBytes;
  final bool deleted;

  const PortfolioEditorState({
    this.status = PortfolioEditorStatus.loading,
    this.portfolio,
    this.roles,
    this.errorMessage,
    this.isSaving = false,
    this.isSharing = false,
    this.isExporting = false,
    this.uploadingItemId,
    this.uploadProgress = 0,
    this.feedback,
    this.pdfBytes,
    this.deleted = false,
  });

  PortfolioEditorState copyWith({
    PortfolioEditorStatus? status,
    PortfolioModel? portfolio,
    PortfolioRolesModel? roles,
    String? errorMessage,
    bool? isSaving,
    bool? isSharing,
    bool? isExporting,
    int? uploadingItemId,
    bool clearUploading = false,
    double? uploadProgress,
    UiFeedback? feedback,
    Uint8List? pdfBytes,
    bool deleted = false,
  }) {
    return PortfolioEditorState(
      status: status ?? this.status,
      portfolio: portfolio ?? this.portfolio,
      roles: roles ?? this.roles,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      isSharing: isSharing ?? this.isSharing,
      isExporting: isExporting ?? this.isExporting,
      uploadingItemId: clearUploading ? null : (uploadingItemId ?? this.uploadingItemId),
      uploadProgress: uploadProgress ?? this.uploadProgress,
      feedback: feedback,
      pdfBytes: pdfBytes,
      deleted: deleted,
    );
  }
}

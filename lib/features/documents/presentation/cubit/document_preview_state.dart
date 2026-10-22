part of 'document_preview_cubit.dart';

enum DocumentPreviewStatus { idle, loading, success, failure }

class DocumentPreviewState {
  final DocumentPreviewStatus status;

  /// The last good preview; kept while a newer one renders.
  final Uint8List? image;
  final String? errorMessage;

  /// The page's orientation, from the last preview (or the expected one before it).
  final bool isLandscape;

  const DocumentPreviewState({
    this.status = DocumentPreviewStatus.idle,
    this.image,
    this.errorMessage,
    this.isLandscape = false,
  });

  /// Width over height of an A4 page.
  double get aspectRatio => isLandscape ? 297 / 210 : 210 / 297;

  DocumentPreviewState copyWith({DocumentPreviewStatus? status, String? errorMessage}) => DocumentPreviewState(
    status: status ?? this.status,
    image: image,
    errorMessage: errorMessage ?? this.errorMessage,
    isLandscape: isLandscape,
  );
}

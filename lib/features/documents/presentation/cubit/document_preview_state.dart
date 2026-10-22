part of 'document_preview_cubit.dart';

enum DocumentPreviewStatus { idle, loading, success, failure }

class DocumentPreviewState {
  final DocumentPreviewStatus status;

  /// The last good preview; kept while a newer one renders.
  final Uint8List? image;
  final String? errorMessage;

  const DocumentPreviewState({this.status = DocumentPreviewStatus.idle, this.image, this.errorMessage});

  DocumentPreviewState copyWith({DocumentPreviewStatus? status, String? errorMessage}) => DocumentPreviewState(
    status: status ?? this.status,
    image: image,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

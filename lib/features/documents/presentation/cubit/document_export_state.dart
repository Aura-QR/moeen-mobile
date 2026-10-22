part of 'document_export_cubit.dart';

enum DocumentExportAction { pdf, image, word, excel, print }

class DocumentExportState {
  /// What is running now; null when idle.
  final DocumentExportAction? activeAction;

  /// The last action that failed, for «إعادة المحاولة».
  final DocumentExportAction? failedAction;

  /// A translation key or an API message.
  final String? errorMessage;

  const DocumentExportState({this.activeAction, this.failedAction, this.errorMessage});

  bool get isBusy => activeAction != null;
}

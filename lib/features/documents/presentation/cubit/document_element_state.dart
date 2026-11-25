part of 'document_element_cubit.dart';

enum DocumentElementStatus { loading, ready, failure }

class DocumentElementState {
  final DocumentElementStatus status;

  /// The elements the picker lists, in order.
  final List<PortfolioElementModel> options;

  /// An element key, or null when the document isn't evidence.
  final String? element;
  final bool isSaving;
  final String? errorMessage;

  /// One-shot fields, cleared by [copyWith] unless passed.
  final bool changed;
  final UiFeedback? feedback;

  const DocumentElementState({
    this.status = DocumentElementStatus.loading,
    this.options = const [],
    this.element,
    this.isSaving = false,
    this.errorMessage,
    this.changed = false,
    this.feedback,
  });

  PortfolioElementModel? get current => options.where((option) => option.key == element).firstOrNull;

  DocumentElementState copyWith({
    DocumentElementStatus? status,
    String? element,
    bool clearElement = false,
    bool? isSaving,
    String? errorMessage,
    bool changed = false,
    UiFeedback? feedback,
  }) {
    return DocumentElementState(
      status: status ?? this.status,
      options: options,
      element: clearElement ? null : (element ?? this.element),
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      changed: changed,
      feedback: feedback,
    );
  }
}

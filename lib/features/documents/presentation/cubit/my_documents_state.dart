part of 'my_documents_cubit.dart';

enum MyDocumentsStatus { loading, success, failure }

class MyDocumentsState {
  final MyDocumentsStatus status;
  final List<DocumentModel> documents;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  /// The type filter; null for every type.
  final String? type;
  final String? errorMessage;

  /// The document a duplicate or delete is running for.
  final int? busyId;

  /// One-shot: cleared by [copyWith] unless passed.
  final UiFeedback? feedback;

  const MyDocumentsState({
    this.status = MyDocumentsStatus.loading,
    this.documents = const [],
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.type,
    this.errorMessage,
    this.busyId,
    this.feedback,
  });

  MyDocumentsState copyWith({
    MyDocumentsStatus? status,
    List<DocumentModel>? documents,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? type,
    bool clearType = false,
    String? errorMessage,
    int? busyId,
    bool clearBusy = false,
    UiFeedback? feedback,
  }) {
    return MyDocumentsState(
      status: status ?? this.status,
      documents: documents ?? this.documents,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      type: clearType ? null : (type ?? this.type),
      errorMessage: errorMessage ?? this.errorMessage,
      busyId: clearBusy ? null : (busyId ?? this.busyId),
      feedback: feedback,
    );
  }
}

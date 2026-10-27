part of 'reading_list_cubit.dart';

enum ReadingListStatus { loading, success, failure }

class ReadingListState {
  final ReadingListStatus status;
  final List<DocumentModel> documents;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final int? busyDocumentId;
  final String? errorMessage;
  final UiFeedback? feedback;

  const ReadingListState({
    this.status = ReadingListStatus.loading,
    this.documents = const [],
    this.page = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.busyDocumentId,
    this.errorMessage,
    this.feedback,
  });

  ReadingListState copyWith({
    ReadingListStatus? status,
    List<DocumentModel>? documents,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    int? busyDocumentId,
    bool clearBusyDocument = false,
    String? errorMessage,
    UiFeedback? feedback,
  }) =>
      ReadingListState(
        status: status ?? this.status,
        documents: documents ?? this.documents,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        busyDocumentId: clearBusyDocument ? null : (busyDocumentId ?? this.busyDocumentId),
        errorMessage: errorMessage ?? this.errorMessage,
        feedback: feedback,
      );
}

part of 'curriculum_books_cubit.dart';

abstract class CurriculumBooksState {}

class CurriculumBooksInitial extends CurriculumBooksState {}

class CurriculumBooksLoading extends CurriculumBooksState {}

class CurriculumBooksLoaded extends CurriculumBooksState {
  final List<CurriculumBookModel> books;
  CurriculumBooksLoaded({required this.books});
}

class CurriculumBooksError extends CurriculumBooksState {
  final List<CurriculumBookModel> books; // keep existing list visible
  final String message;
  CurriculumBooksError({required this.message, this.books = const []});
}

class CurriculumBooksDownloadLoading extends CurriculumBooksState {
  final int bookId;
  final List<CurriculumBookModel> books;
  CurriculumBooksDownloadLoading({required this.bookId, required this.books});
}

class CurriculumBooksDownloadReady extends CurriculumBooksState {
  final CurriculumBookDownloadModel download;
  final List<CurriculumBookModel> books;
  CurriculumBooksDownloadReady({required this.download, required this.books});
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';
import 'package:moean/features/curriculum/data/repositories/curriculum_repository.dart';

part 'curriculum_books_state.dart';

class CurriculumBooksCubit extends Cubit<CurriculumBooksState> {
  static CurriculumBooksCubit get(BuildContext context) => BlocProvider.of(context);

  CurriculumBooksCubit() : super(CurriculumBooksInitial());

  final _repo = CurriculumRepository();
  List<CurriculumBookModel> _books = [];

  // ── Load books list (optionally filtered) ──────────────────────────────────
  Future<void> loadBooks({int? subjectId, int? gradeId}) async {
    emit(CurriculumBooksLoading());
    final result = await _repo.getBooks(subjectId: subjectId, gradeId: gradeId);
    result.fold(
      (error) => emit(CurriculumBooksError(message: error)),
      (books) {
        _books = books;
        emit(CurriculumBooksLoaded(books: books));
      },
    );
  }

  // ── Fetch a signed R2 download URL for a book ──────────────────────────────
  Future<void> getDownloadUrl(int bookId) async {
    emit(CurriculumBooksDownloadLoading(bookId: bookId, books: _books));
    final result = await _repo.getBookDownloadUrl(bookId);
    result.fold(
      (error) => emit(CurriculumBooksError(message: error, books: _books)),
      (download) =>
          emit(CurriculumBooksDownloadReady(download: download, books: _books)),
    );
  }
}

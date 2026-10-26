import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_state.dart';

class MyExamsCubit extends Cubit<MyExamsState> {
  final ExamRepository _examRepository;
  final Duration _searchDebounce;
  Timer? _debounce;

  String _currentTab = 'all';
  String _searchQuery = '';
  int _currentPage = 1;
  MyExamsLoaded? _lastLoaded;

  MyExamsCubit(
    this._examRepository, {
    Duration searchDebounce = const Duration(milliseconds: 500),
  })  : _searchDebounce = searchDebounce,
        super(const MyExamsInitial());

  static MyExamsCubit get(BuildContext context) =>
      BlocProvider.of<MyExamsCubit>(context);

  String get selectedTab => _currentTab;

  MyExamsLoaded? get lastLoaded => _lastLoaded;

  Future<void> fetchExams({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    if (_currentPage == 1 && !isClosed) {
      emit(const MyExamsLoading());
    }

    String? statusQuery;
    if (_currentTab == 'draft') {
      statusQuery = 'draft';
    } else if (_currentTab == 'published') {
      statusQuery = 'published';
    }

    final result = await _examRepository.getMyExams(
      page: _currentPage,
      perPage: 20,
      status: statusQuery,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        _lastLoaded = null;
        if (!isClosed) emit(MyExamsError(failure.message));
      },
      (examsPagination) {
        final previousExpanded = _lastLoaded?.expandedExamId;
        final keepExpanded = previousExpanded != null &&
            examsPagination.data.any((e) => e.id == previousExpanded);

        _lastLoaded = MyExamsLoaded(
          exams: examsPagination,
          selectedTab: _currentTab,
          searchQuery: _searchQuery,
          expandedExamId: keepExpanded ? previousExpanded : null,
        );
        if (!isClosed) emit(_lastLoaded!);
      },
    );
  }

  void toggleExpand(int examId) {
    final current = _lastLoaded;
    if (current == null || isClosed) return;

    final isSame = current.expandedExamId == examId;
    _lastLoaded = current.copyWith(
      expandedExamId: examId,
      clearExpanded: isSame,
    );
    emit(_lastLoaded!);
  }

  void changeTab(String tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    _currentPage = 1;
    fetchExams();
  }

  void searchExams(String query) {
    if (_searchQuery == query && !(_debounce?.isActive ?? false)) return;

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(_searchDebounce, () {
      if (isClosed) return;
      if (_searchQuery == query) return;
      _searchQuery = query;
      _currentPage = 1;
      fetchExams();
    });
  }

  Future<void> publishExam(int examId) async {
    final current = _lastLoaded;
    if (current == null) return;

    if (!isClosed) {
      emit(MyExamsActionLoading(action: 'publish', examId: examId));
    }

    final result = await _examRepository.publishExam(examId);
    if (isClosed) return;

    await result.fold(
      (failure) async {
        if (!isClosed) {
          emit(MyExamsActionError(failure.message));
          emit(current);
        }
      },
      (_) async {
        if (!isClosed) {
          emit(const MyExamsActionSuccess('exam_published_success'));
          await fetchExams(isRefresh: true);
        }
      },
    );
  }

  Future<void> deleteExam(int examId) async {
    final current = _lastLoaded;
    if (current == null) return;

    if (!isClosed) {
      emit(MyExamsActionLoading(action: 'delete', examId: examId));
    }

    final result = await _examRepository.deleteExam(examId);
    if (isClosed) return;

    await result.fold(
      (failure) async {
        if (!isClosed) {
          emit(MyExamsActionError(failure.message));
          emit(current);
        }
      },
      (_) async {
        if (!isClosed) {
          emit(const MyExamsActionSuccess('exam_deleted_success'));
          await fetchExams(isRefresh: true);
        }
      },
    );
  }

  Future<void> openExamPreview(int examId) async {
    final current = _lastLoaded;
    if (current != null && current.isPreviewLoading) return;

    if (current != null) {
      _lastLoaded = current.copyWith(isPreviewLoading: true);
      if (!isClosed) emit(_lastLoaded!);
    }

    final result = await _examRepository.getExam(examId);
    if (isClosed) return;

    result.fold(
      (failure) {
        if (_lastLoaded != null) {
          _lastLoaded = _lastLoaded!.copyWith(isPreviewLoading: false);
        }
        emit(MyExamsActionError(failure.message));
        if (_lastLoaded != null) emit(_lastLoaded!);
      },
      (exam) {
        if (_lastLoaded != null) {
          _lastLoaded = _lastLoaded!.copyWith(isPreviewLoading: false);
        }
        emit(MyExamsPreviewReady(exam));
        if (_lastLoaded != null) emit(_lastLoaded!);
      },
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

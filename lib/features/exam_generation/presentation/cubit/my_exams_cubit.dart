import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_state.dart';

class MyExamsCubit extends Cubit<MyExamsState> {
  final ExamRepository _examRepository;
  Timer? _debounce;
  
  // Internal state tracking
  String _currentTab = 'all'; // 'all', 'draft', 'published'
  String _searchQuery = '';
  int _currentPage = 1;

  MyExamsCubit(this._examRepository) : super(MyExamsInitial());

  static MyExamsCubit get(context) => BlocProvider.of(context);

  void fetchExams({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
    }

    if (_currentPage == 1) {
      if (!isClosed) emit(MyExamsLoading());
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
        if (!isClosed) emit(MyExamsError(failure.message));
      },
      (examsPagination) {
        if (!isClosed) {
          emit(MyExamsLoaded(
            exams: examsPagination,
            selectedTab: _currentTab,
            searchQuery: _searchQuery,
          ));
        }
      },
    );
  }

  void changeTab(String tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    _currentPage = 1;
    fetchExams();
  }

  void searchExams(String query) {
    if (_searchQuery == query) return;
    
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (isClosed) return;
      _searchQuery = query;
      _currentPage = 1;
      fetchExams();
    });
  }

  Future<void> publishExam(int examId) async {
    final currentState = state;
    if (currentState is! MyExamsLoaded) return;
    
    if (!isClosed) emit(MyExamsActionLoading(action: 'publish', examId: examId));
    
    final result = await _examRepository.publishExam(examId);

    if (isClosed) return;
    
    result.fold(
      (failure) {
        if (!isClosed) {
          emit(MyExamsActionError(failure.message));
          // Re-emit loaded state so UI recovers
          emit(currentState);
        }
      },
      (exam) {
        if (!isClosed) {
          emit(MyExamsActionSuccess('تم نشر الاختبار بنجاح'));
          fetchExams(isRefresh: true);
        }
      },
    );
  }

  Future<void> deleteExam(int examId) async {
    final currentState = state;
    if (currentState is! MyExamsLoaded) return;
    
    if (!isClosed) emit(MyExamsActionLoading(action: 'delete', examId: examId));
    
    final result = await _examRepository.deleteExam(examId);

    if (isClosed) return;
    
    result.fold(
      (failure) {
        if (!isClosed) {
          emit(MyExamsActionError(failure.message));
          // Re-emit loaded state so UI recovers
          emit(currentState);
        }
      },
      (_) {
        if (!isClosed) {
          emit(MyExamsActionSuccess('تم حذف الاختبار بنجاح'));
          fetchExams(isRefresh: true);
        }
      },
    );
  }
  
  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

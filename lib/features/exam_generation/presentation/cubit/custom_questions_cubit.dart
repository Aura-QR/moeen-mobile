import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/usecases/get_my_questions_usecase.dart';
import 'package:moean/features/exam_generation/domain/usecases/update_custom_question_usecase.dart';
import 'package:moean/features/exam_generation/presentation/cubit/custom_questions_state.dart';

class CustomQuestionsCubit extends Cubit<CustomQuestionsState> {
  final GetMyQuestionsUseCase _getMyQuestionsUseCase;
  final UpdateCustomQuestionUseCase _updateCustomQuestionUseCase;

  int _currentPage = 1;
  bool _isLastPage = false;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  QuestionPaginationEntity? _currentPagination;

  CustomQuestionsCubit(
    this._getMyQuestionsUseCase,
    this._updateCustomQuestionUseCase,
  ) : super(CustomQuestionsInitial());

  static CustomQuestionsCubit get(context) => BlocProvider.of(context);

  Future<void> fetchQuestions({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _isLastPage = false;
      _currentPagination = null;
      emit(CustomQuestionsLoading());
    } else {
      if (_isLastPage || state is CustomQuestionsLoading) return;
      emit(CustomQuestionsLoading(isPagination: true));
    }

    String? statusFilter = _selectedStatus == 'all' ? null : _selectedStatus;
    String? searchFilter = _searchQuery.isEmpty ? null : _searchQuery;

    final result = await _getMyQuestionsUseCase.execute(
      page: _currentPage,
      reviewStatus: statusFilter,
      search: searchFilter,
    );

    result.fold(
      (failure) {
        if (_currentPagination != null) {
          emit(CustomQuestionsLoaded(
            questions: _currentPagination!,
            selectedStatus: _selectedStatus,
            searchQuery: _searchQuery,
          ));
        } else {
          emit(CustomQuestionsError(failure.message));
        }
      },
      (pagination) {
        _isLastPage = pagination.currentPage >= pagination.lastPage;
        
        if (isRefresh || _currentPagination == null) {
          _currentPagination = pagination;
        } else {
          final currentQuestions = List<QuestionEntity>.from(_currentPagination!.data);
          currentQuestions.addAll(pagination.data);
          _currentPagination = QuestionPaginationEntity(
            currentPage: pagination.currentPage,
            lastPage: pagination.lastPage,
            perPage: pagination.perPage,
            total: pagination.total,
            data: currentQuestions,
          );
        }
        
        if (!_isLastPage) {
          _currentPage++;
        }

        emit(CustomQuestionsLoaded(
          questions: _currentPagination!,
          selectedStatus: _selectedStatus,
          searchQuery: _searchQuery,
        ));
      },
    );
  }

  void changeStatus(String status) {
    _selectedStatus = status;
    fetchQuestions(isRefresh: true);
  }

  void searchQuestions(String query) {
    _searchQuery = query;
    fetchQuestions(isRefresh: true);
  }

  Future<void> updateQuestion(int questionId, Map<String, dynamic> data) async {
    emit(CustomQuestionActionLoading());
    
    final result = await _updateCustomQuestionUseCase.execute(questionId, data);
    
    result.fold(
      (failure) {
        emit(CustomQuestionActionError(failure.message));
        if (_currentPagination != null) {
          emit(CustomQuestionsLoaded(
            questions: _currentPagination!,
            selectedStatus: _selectedStatus,
            searchQuery: _searchQuery,
          ));
        }
      },
      (updatedQuestion) {
        emit(CustomQuestionActionSuccess('تم تحديث السؤال بنجاح'));
        
        if (_currentPagination != null) {
          final updatedList = _currentPagination!.data.map((q) {
            return q.id == questionId ? updatedQuestion : q;
          }).toList();
          
          _currentPagination = QuestionPaginationEntity(
            currentPage: _currentPagination!.currentPage,
            lastPage: _currentPagination!.lastPage,
            perPage: _currentPagination!.perPage,
            total: _currentPagination!.total,
            data: updatedList,
          );
          
          emit(CustomQuestionsLoaded(
            questions: _currentPagination!,
            selectedStatus: _selectedStatus,
            searchQuery: _searchQuery,
          ));
        } else {
          fetchQuestions(isRefresh: true);
        }
      },
    );
  }
}

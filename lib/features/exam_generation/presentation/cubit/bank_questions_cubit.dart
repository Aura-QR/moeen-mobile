import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';

abstract class BankQuestionsState {}

class BankQuestionsInitial extends BankQuestionsState {}

class BankQuestionsLoading extends BankQuestionsState {}

class BankQuestionsError extends BankQuestionsState {
  final String message;
  BankQuestionsError(this.message);
}

class BankQuestionsUpdated extends BankQuestionsState {
  final List<Map<String, dynamic>> questions;
  final List<int> selectedQuestionIds;
  final Map<int, List<int>> allSelectedQuestionIds;
  final int currentPage;
  final int lastPage;
  final bool hasMore;
  final String? selectedType;
  
  BankQuestionsUpdated({
    required this.questions,
    required this.selectedQuestionIds,
    required this.allSelectedQuestionIds,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
    this.selectedType,
  });
}

class BankQuestionsCubit extends Cubit<BankQuestionsState> {
  BankQuestionsCubit() : super(BankQuestionsInitial());

  List<Map<String, dynamic>> _allQuestions = [];
  final Map<int, List<int>> _allSelectedQuestionIds = {};
  int _currentLessonId = -1;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  String? _selectedType;

  void setFilter(String? type) {
    if (_selectedType == type) return;
    _selectedType = type;
    if (_currentLessonId != -1) {
      _currentPage = 1;
      _allQuestions = [];
      emit(BankQuestionsLoading());
      loadQuestionsForLesson(_currentLessonId, refresh: true);
    }
  }

  Future<void> loadQuestionsForLesson(int lessonId, {bool refresh = false}) async {
    if (refresh || _currentLessonId != lessonId) {
      _currentLessonId = lessonId;
      _currentPage = 1;
      _allQuestions = [];
      // Do not clear _allSelectedQuestionIds to keep selection across lessons
      emit(BankQuestionsLoading());
    } else if (_currentPage >= _lastPage || _isLoadingMore) {
      return;
    } else {
      _currentPage++;
      _isLoadingMore = true;
      // Emit state to show loading more if needed, but here we just update state silently
    }

    final result = await ApiService.getLessonQuestions(
      lessonId: _currentLessonId,
      type: _selectedType,
      page: _currentPage,
    );

    result.fold(
      (error) {
        if (_currentPage == 1) {
          emit(BankQuestionsError(error.toString()));
        } else {
          _currentPage--;
          _isLoadingMore = false;
        }
      },
      (data) {
        final List<dynamic> questionsData = data['data'] ?? [];
        final meta = data['meta'] ?? {};
        
        _lastPage = meta['last_page'] ?? 1;
        
        for (var q in questionsData) {
          _allQuestions.add({
            'id': q['id'],
            'type': q['type'],
            'difficulty': q['difficulty'],
            'question_text': q['question_text'],
            'options': q['options'],
            'correct_answer': q['correct_answer'],
          });
        }
        
        _isLoadingMore = false;
        _emitState();
      },
    );
  }

  void toggleQuestion(int questionId) {
    if (_currentLessonId == -1) return;
    _allSelectedQuestionIds[_currentLessonId] ??= [];
    
    if (_allSelectedQuestionIds[_currentLessonId]!.contains(questionId)) {
      _allSelectedQuestionIds[_currentLessonId]!.remove(questionId);
    } else {
      _allSelectedQuestionIds[_currentLessonId]!.add(questionId);
    }
    _emitState();
  }

  void selectAll() {
    if (_currentLessonId == -1) return;
    _allSelectedQuestionIds[_currentLessonId] ??= [];
    
    for (var q in _allQuestions) {
      if (!_allSelectedQuestionIds[_currentLessonId]!.contains(q['id'])) {
        _allSelectedQuestionIds[_currentLessonId]!.add(q['id']);
      }
    }
    _emitState();
  }

  void clearSelection() {
    if (_currentLessonId == -1) return;
    _allSelectedQuestionIds[_currentLessonId]?.clear();
    _emitState();
  }

  void _emitState() {
    final selectedForCurrent = _allSelectedQuestionIds[_currentLessonId] ?? [];
    emit(BankQuestionsUpdated(
      questions: List.from(_allQuestions),
      selectedQuestionIds: List.from(selectedForCurrent),
      allSelectedQuestionIds: Map.from(_allSelectedQuestionIds),
      currentPage: _currentPage,
      lastPage: _lastPage,
      hasMore: _currentPage < _lastPage,
      selectedType: _selectedType,
    ));
  }
  
  Map<int, List<int>> get allSelectedQuestionIds => Map.from(_allSelectedQuestionIds);
}

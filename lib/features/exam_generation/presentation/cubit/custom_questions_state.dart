import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

abstract class CustomQuestionsState {}

class CustomQuestionsInitial extends CustomQuestionsState {}

class CustomQuestionsLoading extends CustomQuestionsState {
  final bool isPagination;
  CustomQuestionsLoading({this.isPagination = false});
}

class CustomQuestionsLoaded extends CustomQuestionsState {
  final QuestionPaginationEntity questions;
  final String selectedStatus;
  final String searchQuery;

  CustomQuestionsLoaded({
    required this.questions,
    this.selectedStatus = 'all',
    this.searchQuery = '',
  });

  CustomQuestionsLoaded copyWith({
    QuestionPaginationEntity? questions,
    String? selectedStatus,
    String? searchQuery,
  }) {
    return CustomQuestionsLoaded(
      questions: questions ?? this.questions,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomQuestionsError extends CustomQuestionsState {
  final String message;

  CustomQuestionsError(this.message);
}

class CustomQuestionActionLoading extends CustomQuestionsState {}

class CustomQuestionActionSuccess extends CustomQuestionsState {
  final String message;

  CustomQuestionActionSuccess(this.message);
}

class CustomQuestionActionError extends CustomQuestionsState {
  final String message;

  CustomQuestionActionError(this.message);
}

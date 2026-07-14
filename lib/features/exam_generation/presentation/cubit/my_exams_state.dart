import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

abstract class MyExamsState {}

class MyExamsInitial extends MyExamsState {}

class MyExamsLoading extends MyExamsState {}

class MyExamsLoaded extends MyExamsState {
  final ExamPaginationEntity exams;
  final String selectedTab; // 'all', 'draft', 'published'
  final String searchQuery;

  MyExamsLoaded({
    required this.exams,
    this.selectedTab = 'all',
    this.searchQuery = '',
  });

  MyExamsLoaded copyWith({
    ExamPaginationEntity? exams,
    String? selectedTab,
    String? searchQuery,
  }) {
    return MyExamsLoaded(
      exams: exams ?? this.exams,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class MyExamsError extends MyExamsState {
  final String message;

  MyExamsError(this.message);
}

class MyExamsActionLoading extends MyExamsState {
  final String action; // 'publish' or 'delete'
  final int examId;

  MyExamsActionLoading({required this.action, required this.examId});
}

class MyExamsActionSuccess extends MyExamsState {
  final String message;

  MyExamsActionSuccess(this.message);
}

class MyExamsActionError extends MyExamsState {
  final String message;

  MyExamsActionError(this.message);
}

import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';

abstract class MyExamsState {
  const MyExamsState();
}

class MyExamsInitial extends MyExamsState {
  const MyExamsInitial();
}

class MyExamsLoading extends MyExamsState {
  const MyExamsLoading();
}

class MyExamsLoaded extends MyExamsState {
  final ExamPaginationEntity exams;
  final String selectedTab;
  final String searchQuery;
  final int? expandedExamId;
  final bool isPreviewLoading;

  const MyExamsLoaded({
    required this.exams,
    this.selectedTab = 'all',
    this.searchQuery = '',
    this.expandedExamId,
    this.isPreviewLoading = false,
  });

  MyExamsLoaded copyWith({
    ExamPaginationEntity? exams,
    String? selectedTab,
    String? searchQuery,
    int? expandedExamId,
    bool clearExpanded = false,
    bool? isPreviewLoading,
  }) {
    return MyExamsLoaded(
      exams: exams ?? this.exams,
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      expandedExamId:
          clearExpanded ? null : (expandedExamId ?? this.expandedExamId),
      isPreviewLoading: isPreviewLoading ?? this.isPreviewLoading,
    );
  }
}

class MyExamsError extends MyExamsState {
  final String message;

  const MyExamsError(this.message);
}

class MyExamsActionLoading extends MyExamsState {
  final String action;
  final int examId;

  const MyExamsActionLoading({required this.action, required this.examId});
}

class MyExamsActionSuccess extends MyExamsState {
  final String message;

  const MyExamsActionSuccess(this.message);
}

class MyExamsActionError extends MyExamsState {
  final String message;

  const MyExamsActionError(this.message);
}

class MyExamsPreviewReady extends MyExamsState {
  final ExamEntity exam;

  const MyExamsPreviewReady(this.exam);
}

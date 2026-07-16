import 'package:moean/features/admin/exams/domain/entities/admin_exam_entities.dart';

abstract class AdminExamsState {}

class AdminExamsInitial extends AdminExamsState {}

class AdminExamsLoading extends AdminExamsState {}

class AdminExamsLoaded extends AdminExamsState {
  final AdminQuestionPaginationEntity pagination;

  AdminExamsLoaded(this.pagination);
}

class AdminExamsError extends AdminExamsState {
  final String message;

  AdminExamsError(this.message);
}

class AdminExamReviewLoading extends AdminExamsState {
  final int questionId;

  AdminExamReviewLoading(this.questionId);
}

class AdminExamReviewSuccess extends AdminExamsState {
  final AdminQuestionEntity updatedQuestion;

  AdminExamReviewSuccess(this.updatedQuestion);
}

class AdminExamReviewError extends AdminExamsState {
  final String message;

  AdminExamReviewError(this.message);
}

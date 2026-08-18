import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/admin/exams/domain/entities/admin_exam_entities.dart';
import 'package:moean/features/admin/exams/domain/usecases/get_pending_questions_usecase.dart';
import 'package:moean/features/admin/exams/domain/usecases/review_question_usecase.dart';
import 'package:moean/features/admin/exams/presentation/cubit/admin_exams_state.dart';

class AdminExamsCubit extends Cubit<AdminExamsState> {
  final GetPendingQuestionsUseCase getPendingQuestionsUseCase;
  final ReviewQuestionUseCase reviewQuestionUseCase;

  AdminExamsCubit({
    required this.getPendingQuestionsUseCase,
    required this.reviewQuestionUseCase,
  }) : super(AdminExamsInitial());

  AdminQuestionPaginationEntity? currentPagination;
  final List<AdminQuestionEntity> _questions = [];

  Future<void> fetchPendingQuestions({
    int page = 1,
    String? type,
    String? difficulty,
    int? lessonId,
  }) async {
    if (page == 1) {
      if (!isClosed) emit(AdminExamsLoading());
      _questions.clear();
      currentPagination = null;
    }

    final result = await getPendingQuestionsUseCase(
      page: page,
      type: type,
      difficulty: difficulty,
      lessonId: lessonId,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        if (page == 1) {
          if (!isClosed) emit(AdminExamsError(failure.message));
        }
      },
      (pagination) {
        currentPagination = pagination;
        if (page == 1) {
          _questions.addAll(pagination.data);
        } else {
          _questions.addAll(pagination.data);
        }
        
        // We replace the pagination data with our accumulated list so the UI gets all items
        final updatedPagination = AdminQuestionPaginationEntity(
          currentPage: pagination.currentPage,
          lastPage: pagination.lastPage,
          perPage: pagination.perPage,
          total: pagination.total,
          data: List.from(_questions),
        );
        currentPagination = updatedPagination;
        if (!isClosed) emit(AdminExamsLoaded(updatedPagination));
      },
    );
  }

  Future<void> reviewQuestion(int questionId, String decision, [String? rejectionReason]) async {
    final currentState = state;
    
    if (!isClosed) emit(AdminExamReviewLoading(questionId));

    final result = await reviewQuestionUseCase(
      questionId: questionId,
      decision: decision,
      rejectionReason: rejectionReason,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) {
          emit(AdminExamReviewError(failure.message));
          if (currentState is AdminExamsLoaded) {
            emit(currentState);
          } else if (currentPagination != null) {
            final updatedPagination = AdminQuestionPaginationEntity(
              currentPage: currentPagination!.currentPage,
              lastPage: currentPagination!.lastPage,
              perPage: currentPagination!.perPage,
              total: currentPagination!.total,
              data: List.from(_questions),
            );
            currentPagination = updatedPagination;
            emit(AdminExamsLoaded(updatedPagination));
          }
        }
      },
      (updatedQuestion) {
        final index = _questions.indexWhere((q) => q.id == questionId);
        if (index != -1) {
          _questions[index] = updatedQuestion;
        }
        if (!isClosed) {
          emit(AdminExamReviewSuccess(updatedQuestion));
          
          if (currentPagination != null) {
            final updatedPagination = AdminQuestionPaginationEntity(
              currentPage: currentPagination!.currentPage,
              lastPage: currentPagination!.lastPage,
              perPage: currentPagination!.perPage,
              total: currentPagination!.total,
              data: List.from(_questions),
            );
            currentPagination = updatedPagination;
            emit(AdminExamsLoaded(updatedPagination));
          }
        }
      },
    );
  }
}

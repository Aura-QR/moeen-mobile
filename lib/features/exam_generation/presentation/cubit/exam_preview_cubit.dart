import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/usecases/get_exam_usecase.dart';
import 'package:moean/features/exam_generation/domain/usecases/update_question_points_usecase.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';
import 'package:moean/core/errors/failures.dart';

abstract class ExamPreviewState {}

class ExamPreviewInitial extends ExamPreviewState {}

class ExamPreviewLoading extends ExamPreviewState {}

class ExamPreviewLoaded extends ExamPreviewState {
  final ExamEntity exam;
  final bool isTeacherMode;
  final bool showAnswers;
  
  // Local changes for provisional calculation before saving
  final Map<int, double> pendingPointsChanges;

  ExamPreviewLoaded({
    required this.exam,
    this.isTeacherMode = true,
    this.showAnswers = true,
    this.pendingPointsChanges = const {},
  });
  
  double get provisionalTotalPoints {
    double total = 0.0;
    for (var q in exam.questions) {
      if (pendingPointsChanges.containsKey(q.id)) {
        total += pendingPointsChanges[q.id]!;
      } else {
        total += q.points;
      }
    }
    return total;
  }

  ExamPreviewLoaded copyWith({
    ExamEntity? exam,
    bool? isTeacherMode,
    bool? showAnswers,
    Map<int, double>? pendingPointsChanges,
  }) {
    return ExamPreviewLoaded(
      exam: exam ?? this.exam,
      isTeacherMode: isTeacherMode ?? this.isTeacherMode,
      showAnswers: showAnswers ?? this.showAnswers,
      pendingPointsChanges: pendingPointsChanges ?? this.pendingPointsChanges,
    );
  }
}

class ExamPreviewError extends ExamPreviewState {
  final String message;
  ExamPreviewError(this.message);
}

class ExamPreviewPaymentRequired extends ExamPreviewState {
  final String message;
  final String code;
  final ExamPreviewLoaded loadedState; // So we can revert safely
  ExamPreviewPaymentRequired(this.message, this.code, this.loadedState);
}

class ExamPreviewSaving extends ExamPreviewLoaded {
  ExamPreviewSaving(ExamPreviewLoaded state) : super(
    exam: state.exam,
    isTeacherMode: state.isTeacherMode,
    showAnswers: state.showAnswers,
    pendingPointsChanges: state.pendingPointsChanges,
  );
}

class ExamPreviewCubit extends Cubit<ExamPreviewState> {
  final GetExamUseCase getExamUseCase;
  final UpdateQuestionPointsUseCase updateQuestionPointsUseCase;
  final ExamRepository examRepository;

  ExamPreviewCubit({
    required this.getExamUseCase,
    required this.updateQuestionPointsUseCase,
    required this.examRepository,
  }) : super(ExamPreviewInitial());

  Future<void> loadExam(int id) async {
    if (!isClosed) emit(ExamPreviewLoading());

    final result = await getExamUseCase.execute(id);
    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) emit(ExamPreviewError(failure.message));
      },
      (exam) {
        if (!isClosed) emit(ExamPreviewLoaded(exam: exam));
      },
    );
  }

  void toggleMode(bool isTeacher) {
    if (state is ExamPreviewLoaded) {
      final current = state as ExamPreviewLoaded;
      if (!isClosed) {
        emit(ExamPreviewLoaded(
          exam: current.exam,
          isTeacherMode: isTeacher,
          showAnswers: current.showAnswers,
          pendingPointsChanges: current.pendingPointsChanges,
        ));
      }
    }
  }

  void toggleAnswers(bool show) {
    if (state is ExamPreviewLoaded) {
      final current = state as ExamPreviewLoaded;
      if (!isClosed) {
        emit(ExamPreviewLoaded(
          exam: current.exam,
          isTeacherMode: current.isTeacherMode,
          showAnswers: show,
          pendingPointsChanges: current.pendingPointsChanges,
        ));
      }
    }
  }

  void updatePendingPoints(int questionId, double points) {
    if (state is ExamPreviewLoaded) {
      final currentState = state as ExamPreviewLoaded;
      final newPending = Map<int, double>.from(currentState.pendingPointsChanges);
      newPending[questionId] = points;
      
      if (!isClosed) {
        emit(currentState.copyWith(
          pendingPointsChanges: newPending,
        ));
      }
    }
  }

  Future<void> addManualQuestion(Map<String, dynamic> request) async {
    if (state is ExamPreviewLoaded) {
      final loadedState = state as ExamPreviewLoaded;
      if (!isClosed) emit(ExamPreviewSaving(loadedState));

      final result = await examRepository.addManualQuestion(request);
      if (isClosed) return;

      result.fold(
        (failure) {
          if (!isClosed) {
            if (failure is PaymentRequiredFailure) {
              emit(ExamPreviewPaymentRequired(failure.message, failure.code, loadedState));
            } else {
              emit(ExamPreviewError(failure.message));
            }
            // Restore previous state
            emit(loadedState);
          }
        },
        (updatedExam) {
          if (!isClosed) {
            emit(ExamPreviewLoaded(
              exam: updatedExam,
              isTeacherMode: loadedState.isTeacherMode,
              showAnswers: loadedState.showAnswers,
              pendingPointsChanges: const {},
            ));
          }
        },
      );
    }
  }

  Future<void> savePoints() async {
    if (state is! ExamPreviewLoaded) return;
    
    final current = state as ExamPreviewLoaded;
    if (current.pendingPointsChanges.isEmpty) return; // nothing to save

    final examId = current.exam.id;
    
    // Prepare the list of questions to update
    final updates = current.pendingPointsChanges.entries.map((e) {
      return {
        'question_id': e.key,
        'points': e.value,
      };
    }).toList();

    if (!isClosed) emit(ExamPreviewSaving(current));

    final result = await updateQuestionPointsUseCase.execute(examId, updates);
    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) {
          emit(ExamPreviewError(failure.message));
          // Reload exam after failure to reset UI to actual backend state
          loadExam(examId);
        }
      },
      (exam) {
        if (!isClosed) emit(ExamPreviewLoaded(exam: exam, pendingPointsChanges: const {})); // Clear pending on success
      },
    );
  }
}

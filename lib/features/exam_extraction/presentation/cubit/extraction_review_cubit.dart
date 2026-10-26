import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/data/repositories/exam_extraction_repository.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_state.dart';

class ExtractionReviewCubit extends Cubit<ExtractionReviewState> {
  final ExamExtractionRepository _repository;

  ExtractionReviewCubit({
    required ExamExtractionRepository repository,
    List<ExtractedQuestionModel> initialQuestions = const [],
    String? source,
  })  : _repository = repository,
        super(ExtractionReviewState(
          questions: initialQuestions,
          source: source,
        ));

  static ExtractionReviewCubit get(BuildContext context) =>
      BlocProvider.of(context);

  void setTitle(String title) {
    emit(state.copyWith(title: title, clearError: true));
  }

  void setLesson(PickedLessonModel? lesson) {
    emit(state.copyWith(lesson: lesson, clearError: true));
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void updateText(int index, String text) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<ExtractedQuestionModel>.from(state.questions);
    updated[index] = updated[index].copyWith(questionText: text);
    emit(state.copyWith(questions: updated, clearError: true));
  }

  void updateOptions(int index, List<String> options) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<ExtractedQuestionModel>.from(state.questions);
    updated[index] = updated[index].copyWith(options: options);
    emit(state.copyWith(questions: updated, clearError: true));
  }

  void setCorrectAnswer(int index, String answer) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<ExtractedQuestionModel>.from(state.questions);
    updated[index] = updated[index].copyWith(
      correctAnswer: answer,
      suggested: false,
    );
    emit(state.copyWith(questions: updated, clearError: true));
  }

  void setTrueFalse(int index, bool isTrue) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<ExtractedQuestionModel>.from(state.questions);
    updated[index] = updated[index].copyWith(
      correctAnswer: isTrue
          ? ExtractedQuestionModel.answerTrue
          : ExtractedQuestionModel.answerFalse,
      suggested: false,
    );
    emit(state.copyWith(questions: updated, clearError: true));
  }

  void updateColumnA(int index, List<String> columnA) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<ExtractedQuestionModel>.from(state.questions);
    updated[index] = updated[index].copyWith(columnA: columnA);
    emit(state.copyWith(questions: updated, clearError: true));
  }

  void updateColumnB(int index, List<String> columnB) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<ExtractedQuestionModel>.from(state.questions);
    updated[index] = updated[index].copyWith(columnB: columnB);
    emit(state.copyWith(questions: updated, clearError: true));
  }

  void setPoints(int index, double points) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<ExtractedQuestionModel>.from(state.questions);
    updated[index] = updated[index].copyWith(points: points > 0 ? points : 1.0);
    emit(state.copyWith(questions: updated, clearError: true));
  }

  void changeType(int index, String newType) {
    if (index < 0 || index >= state.questions.length) return;
    final current = state.questions[index];
    if (current.type == newType) return;

    ExtractedQuestionModel modified;
    if (newType == QuestionType.trueFalse) {
      modified = current.copyWith(
        type: newType,
        options: const [],
        columnA: const [],
        columnB: const [],
        correctAnswer: ExtractedQuestionModel.answerTrue,
        suggested: false,
      );
    } else if (newType == QuestionType.mcq) {
      modified = current.copyWith(
        type: newType,
        options: const [],
        columnA: const [],
        columnB: const [],
        correctAnswer: '',
        suggested: false,
      );
    } else if (newType == QuestionType.matching) {
      modified = current.copyWith(
        type: newType,
        options: const [],
        columnA: const [],
        columnB: const [],
        correctAnswer: '',
        suggested: false,
      );
    } else {
      // fill_blank or essay
      modified = current.copyWith(
        type: newType,
        options: const [],
        columnA: const [],
        columnB: const [],
        correctAnswer: '',
        suggested: false,
      );
    }

    final updated = List<ExtractedQuestionModel>.from(state.questions);
    updated[index] = modified;
    emit(state.copyWith(questions: updated, clearError: true));
  }

  void delete(int index) {
    if (index < 0 || index >= state.questions.length) return;
    final updated = List<ExtractedQuestionModel>.from(state.questions)
      ..removeAt(index);
    emit(state.copyWith(questions: updated, clearError: true));
  }

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(
      isSaving: true,
      error: null,
      paymentRequired: false,
      clearError: true,
    ));

    final result = await _repository.saveExam(
      title: state.title.trim(),
      lessonId: state.lesson!.lessonId,
      questions: state.questions,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (failure is PaymentRequiredFailure) {
          emit(state.copyWith(
            isSaving: false,
            paymentRequired: true,
            error: failure.message,
          ));
        } else {
          emit(state.copyWith(
            isSaving: false,
            error: failure.message,
          ));
        }
      },
      (_) {
        emit(state.copyWith(
          isSaving: false,
          saved: true,
        ));
      },
    );
  }
}

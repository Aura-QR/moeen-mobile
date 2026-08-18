import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/exam_generation/domain/usecases/add_manual_question_usecase.dart';
import 'manual_exam_state.dart';
import 'package:moean/core/errors/failures.dart';

class ManualExamCubit extends Cubit<ManualExamState> {
  final AddManualQuestionUseCase addManualQuestionUseCase;

  String selectedQuestionType = 'mcq';
  int? selectedLessonId;
  
  final TextEditingController gradeController = TextEditingController(text: '1');
  final TextEditingController questionTextController = TextEditingController();
  final TextEditingController correctAnswerController = TextEditingController();
  
  List<TextEditingController> optionsControllers = [
    TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController()
  ];
  
  List<TextEditingController> columnAControllers = [TextEditingController(), TextEditingController()];
  List<TextEditingController> columnBControllers = [TextEditingController(), TextEditingController()];

  ManualExamCubit(this.addManualQuestionUseCase) : super(ManualExamInitial());

  static ManualExamCubit get(context) => BlocProvider.of(context);

  void changeQuestionType(String type) {
    selectedQuestionType = type;
    emit(ManualExamFormUpdated());
  }

  void updateGrade(String newGrade) {}

  void updateLesson(int lessonId) {
    selectedLessonId = lessonId;
    emit(ManualExamFormUpdated());
  }

  void addOption() {
    optionsControllers.add(TextEditingController());
    emit(ManualExamFormUpdated());
  }

  void removeOption(int index) {
    if (optionsControllers.length > 2) {
      optionsControllers[index].dispose();
      optionsControllers.removeAt(index);
      emit(ManualExamFormUpdated());
    }
  }

  void addMatchingItem() {
    columnAControllers.add(TextEditingController());
    columnBControllers.add(TextEditingController());
    emit(ManualExamFormUpdated());
  }

  void removeMatchingItem(int index) {
    if (columnAControllers.length > 2) {
      columnAControllers[index].dispose();
      columnBControllers[index].dispose();
      columnAControllers.removeAt(index);
      columnBControllers.removeAt(index);
      emit(ManualExamFormUpdated());
    }
  }

  Future<void> submitQuestion(int examId) async {
    final questionText = questionTextController.text;
    if (selectedLessonId == null || questionText.trim().isEmpty) {
      emit(ManualExamError('Please fill all required fields'));
      return;
    }

    if (!isClosed) emit(ManualExamLoading());

    final request = <String, dynamic>{
      'exam_id': examId,
      'lesson_id': selectedLessonId,
      'type': selectedQuestionType,
      'question_text': questionText.trim(),
      'points': double.tryParse(gradeController.text) ?? 1.0,
    };

    final correctAnswer = correctAnswerController.text.trim();

    if (selectedQuestionType == 'mcq') {
      final validOptions = optionsControllers.map((c) => c.text.trim()).where((o) => o.isNotEmpty).toList();
      if (validOptions.length < 2) {
        if (!isClosed) emit(ManualExamError('MCQ requires at least 2 options'));
        return;
      }
      if (!validOptions.contains(correctAnswer)) {
         if (!isClosed) emit(ManualExamError('Correct answer must match one of the options'));
         return;
      }
      request['options'] = validOptions;
      request['correct_answer'] = correctAnswer;
    } else if (selectedQuestionType == 'matching') {
      final validColA = columnAControllers.map((c) => c.text.trim()).where((o) => o.isNotEmpty).toList();
      final validColB = columnBControllers.map((c) => c.text.trim()).where((o) => o.isNotEmpty).toList();
      if (validColA.isEmpty || validColB.isEmpty) {
        if (!isClosed) emit(ManualExamError('Matching columns cannot be empty'));
        return;
      }
      request['options'] = {
        'column_a': validColA,
        'column_b': validColB,
      };
      request['correct_answer'] = correctAnswer;
    } else {
      // True/False, Essay, Fill Blank
      request['correct_answer'] = correctAnswer;
    }

    final result = await addManualQuestionUseCase(request);
    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) {
          if (failure is PaymentRequiredFailure) {
            emit(ManualExamPaymentRequired(failure.message, failure.code));
          } else {
            emit(ManualExamError(failure.message));
          }
        }
      },
      (exam) {
        if (!isClosed) emit(ManualExamSuccess('Question added successfully'));
      },
    );
  }

  @override
  Future<void> close() {
    gradeController.dispose();
    questionTextController.dispose();
    correctAnswerController.dispose();
    for (var c in optionsControllers) { c.dispose(); }
    for (var c in columnAControllers) { c.dispose(); }
    for (var c in columnBControllers) { c.dispose(); }
    return super.close();
  }
}

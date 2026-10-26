import 'package:equatable/equatable.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';

class ExtractionReviewState extends Equatable {
  final List<ExtractedQuestionModel> questions;
  final String? source;
  final String title;
  final PickedLessonModel? lesson;
  final bool isSaving;
  final String? error;
  final bool paymentRequired;
  final bool saved;

  const ExtractionReviewState({
    this.questions = const [],
    this.source,
    this.title = '',
    this.lesson,
    this.isSaving = false,
    this.error,
    this.paymentRequired = false,
    this.saved = false,
  });

  bool get canSave =>
      questions.isNotEmpty &&
      questions.every((q) => q.isValid) &&
      title.trim().isNotEmpty &&
      lesson != null &&
      !isSaving;

  int get missingCount => questions.where((q) => !q.isValid).length;

  ExtractionReviewState copyWith({
    List<ExtractedQuestionModel>? questions,
    String? source,
    String? title,
    PickedLessonModel? lesson,
    bool? isSaving,
    String? error,
    bool? paymentRequired,
    bool? saved,
    bool clearError = false,
    bool clearLesson = false,
  }) {
    return ExtractionReviewState(
      questions: questions ?? this.questions,
      source: source ?? this.source,
      title: title ?? this.title,
      lesson: clearLesson ? null : (lesson ?? this.lesson),
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      paymentRequired: paymentRequired ?? this.paymentRequired,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        source,
        title,
        lesson,
        isSaving,
        error,
        paymentRequired,
        saved,
      ];
}

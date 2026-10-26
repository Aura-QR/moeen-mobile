import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/data/repositories/exam_extraction_repository.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';

class MockExamExtractionRepository extends Mock
    implements ExamExtractionRepository {}

void main() {
  late MockExamExtractionRepository mockRepo;
  late ExtractionReviewCubit cubit;

  const validQuestion = ExtractedQuestionModel(
    type: QuestionType.mcq,
    questionText: 'سؤال 1',
    options: ['خيار 1', 'خيار 2'],
    correctAnswer: 'خيار 1',
    suggested: true,
  );

  const testLesson = PickedLessonModel(
    lessonId: 10,
    lessonTitle: 'الدرس الأول',
    subjectName: 'علوم',
    gradeName: 'رابع',
  );

  setUp(() {
    mockRepo = MockExamExtractionRepository();
    cubit = ExtractionReviewCubit(
      repository: mockRepo,
      initialQuestions: [validQuestion],
      source: 'questions',
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ExtractionReviewCubit', () {
    test('canSave is false when title or lesson is missing', () {
      expect(cubit.state.canSave, isFalse);

      cubit.setTitle('اختبار العلوم');
      expect(cubit.state.canSave, isFalse);

      cubit.setLesson(testLesson);
      expect(cubit.state.canSave, isTrue);
    });

    test('editing a suggested answer clears suggested flag', () {
      expect(cubit.state.questions.first.suggested, isTrue);

      cubit.setCorrectAnswer(0, 'خيار 2');

      expect(cubit.state.questions.first.correctAnswer, 'خيار 2');
      expect(cubit.state.questions.first.suggested, isFalse);
    });

    test('mcq mismatch blocks canSave', () {
      cubit.setTitle('اختبار العلوم');
      cubit.setLesson(testLesson);
      expect(cubit.state.canSave, isTrue);

      // Set answer to something not in options
      cubit.setCorrectAnswer(0, 'خيار غير موجود');

      expect(cubit.state.questions.first.mcqAnswerMismatch, isTrue);
      expect(cubit.state.canSave, isFalse);
    });

    test('delete removes question and updates state', () {
      expect(cubit.state.questions.length, 1);

      cubit.delete(0);

      expect(cubit.state.questions, isEmpty);
      expect(cubit.state.canSave, isFalse);
    });

    test('changeType resets options and answer correctly', () {
      cubit.changeType(0, QuestionType.trueFalse);

      final q = cubit.state.questions.first;
      expect(q.type, QuestionType.trueFalse);
      expect(q.correctAnswer, ExtractedQuestionModel.answerTrue);
      expect(q.options, isEmpty);
    });

    test('save calls repository and emits saved: true on success', () async {
      cubit.setTitle('اختبار العلوم');
      cubit.setLesson(testLesson);

      when(() => mockRepo.saveExam(
            title: 'اختبار العلوم',
            lessonId: 10,
            questions: any(named: 'questions'),
          )).thenAnswer((_) async => const Right(unit));

      await cubit.save();

      expect(cubit.state.saved, isTrue);
      expect(cubit.state.isSaving, isFalse);
    });

    test('save emits error when repository returns failure', () async {
      cubit.setTitle('اختبار العلوم');
      cubit.setLesson(testLesson);

      when(() => mockRepo.saveExam(
            title: 'اختبار العلوم',
            lessonId: 10,
            questions: any(named: 'questions'),
          )).thenAnswer((_) async => const Left(ServerFailure('invalid_data')));

      await cubit.save();

      expect(cubit.state.saved, isFalse);
      expect(cubit.state.error, 'invalid_data');
    });

    test('save emits paymentRequired when repository returns 402', () async {
      cubit.setTitle('اختبار العلوم');
      cubit.setLesson(testLesson);

      when(() => mockRepo.saveExam(
            title: 'اختبار العلوم',
            lessonId: 10,
            questions: any(named: 'questions'),
          )).thenAnswer((_) async => const Left(PaymentRequiredFailure('no_plan')));

      await cubit.save();

      expect(cubit.state.paymentRequired, isTrue);
    });
  });
}

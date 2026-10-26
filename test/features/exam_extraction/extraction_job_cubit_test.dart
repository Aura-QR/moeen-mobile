import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_extraction/data/models/extracted_question_model.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_job_model.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_page_model.dart';
import 'package:moean/features/exam_extraction/data/repositories/exam_extraction_repository.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_job_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_job_state.dart';

class MockExamExtractionRepository extends Mock
    implements ExamExtractionRepository {}

void main() {
  late MockExamExtractionRepository mockRepo;
  late ExtractionJobCubit cubit;

  final testPages = [
    ExtractionPageModel(
      bytes: Uint8List.fromList([1, 2, 3]),
      name: 'page1.jpg',
      mime: 'image/jpeg',
    ),
  ];

  setUp(() {
    mockRepo = MockExamExtractionRepository();
    cubit = ExtractionJobCubit(
      repository: mockRepo,
      pollInterval: Duration.zero,
      maxAttempts: 3,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ExtractionJobCubit', () {
    test('polls until job is done with questions', () async {
      const pendingJob = ExtractionJobModel(id: 1, status: 'pending');
      const doneJob = ExtractionJobModel(
        id: 1,
        status: 'done',
        source: 'questions',
        questions: [
          ExtractedQuestionModel(
            type: QuestionType.mcq,
            questionText: 'سؤال 1',
            options: ['أ', 'ب'],
            correctAnswer: 'أ',
          ),
        ],
      );

      when(() => mockRepo.start(
            pages: testPages,
            count: 10,
            notes: null,
          )).thenAnswer((_) async => const Right(pendingJob));

      when(() => mockRepo.getJob(1))
          .thenAnswer((_) async => const Right(doneJob));

      cubit.start(pages: testPages, count: 10);

      await untilCalled(() => mockRepo.getJob(1));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.status, ExtractionJobStatus.done);
      expect(cubit.state.job?.questions.length, 1);
    });

    test('emits failed when done job has 0 questions', () async {
      const doneJobEmpty = ExtractionJobModel(
        id: 2,
        status: 'done',
        questions: [],
      );

      when(() => mockRepo.start(
            pages: testPages,
            count: 10,
            notes: null,
          )).thenAnswer((_) async => const Right(doneJobEmpty));

      cubit.start(pages: testPages, count: 10);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.status, ExtractionJobStatus.failed);
      expect(cubit.state.error, 'exam_extract_no_questions');
    });

    test('emits paymentRequired when start returns 402 PaymentRequiredFailure', () async {
      when(() => mockRepo.start(
            pages: testPages,
            count: 10,
            notes: null,
          )).thenAnswer((_) async => const Left(PaymentRequiredFailure('no_plan')));

      cubit.start(pages: testPages, count: 10);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.status, ExtractionJobStatus.failed);
      expect(cubit.state.paymentRequired, isTrue);
    });

    test('emits timedOut after maxAttempts exceeded without done/failed', () async {
      const pendingJob = ExtractionJobModel(id: 3, status: 'pending');

      when(() => mockRepo.start(
            pages: testPages,
            count: 10,
            notes: null,
          )).thenAnswer((_) async => const Right(pendingJob));

      when(() => mockRepo.getJob(3))
          .thenAnswer((_) async => const Right(pendingJob));

      cubit.start(pages: testPages, count: 10);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.status, ExtractionJobStatus.timedOut);
      expect(cubit.state.error, 'exam_extract_timeout');
    });

    test('shows 429 message as-is on failure', () async {
      when(() => mockRepo.start(
            pages: testPages,
            count: 10,
            notes: null,
          )).thenAnswer((_) async => const Left(ServerFailure('usage_limit_reached')));

      cubit.start(pages: testPages, count: 10);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.status, ExtractionJobStatus.failed);
      expect(cubit.state.error, 'usage_limit_reached');
    });
  });
}

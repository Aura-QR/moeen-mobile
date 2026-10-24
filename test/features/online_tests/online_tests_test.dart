import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';
import 'package:moean/features/online_tests/data/repositories/online_tests_repository.dart';
import 'package:moean/features/online_tests/presentation/cubit/create_online_test_cubit.dart';
import 'package:moean/features/online_tests/presentation/cubit/online_test_cubit.dart';
import 'package:moean/features/online_tests/presentation/cubit/submission_review_cubit.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';

class MockOnlineTestsRepository extends Mock implements OnlineTestsRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockClassesRepository extends Mock implements ClassesRepository {}

class _Failure extends Failure {
  const _Failure(super.message);
}

OnlineTestResults _results({int waiting = 0, int suggested = 0}) => OnlineTestResults.fromJson({
      'groups': [
        {'id': 1, 'name': 'رابع 1', 'average': 4.5, 'submissions': [
          {'id': 9, 'group_id': 1, 'student_name': 'أحمد', 'score': 3, 'needs_review': true, 'ai_suggested': suggested, 'fields': []},
        ]},
      ],
      'questions': [],
      'to_review': 1,
      'ai': {'waiting': waiting, 'suggested': suggested},
    });

void main() {
  setUpAll(() {
    registerFallbackValue(const NewOnlineTest(examId: 0, title: '', groups: []));
    registerFallbackValue(<int, double?>{});
  });

  group('models', () {
    test('a test and its links are read, and points print without «.0»', () {
      final test = OnlineTest.fromJson({
        'id': 3, 'title': 'اختبار النبات', 'questions_count': 4, 'total_points': 10.0, 'is_open': true, 'state': 'open',
        'submissions': 2, 'settings': {'time_limit_minutes': 20},
        'groups': [{'id': 1, 'name': 'رابع 1', 'url': 'https://haderedu.com/t/abc', 'submissions': 2, 'qr': 'data:image/png;base64,AA=='}],
      });
      expect(test.groups.single.url, endsWith('/t/abc'));
      expect(test.timeLimitMinutes, 20);
      expect(formatPoints(test.totalPoints), '10');
      expect(formatPoints(3.5), '3.5');
      expect(formatPoints(null), '—');
    });

    test('a matching answer reads as «item ← choice», and the AI suggestion is kept apart from the mark', () {
      final a = SubmissionAnswer.fromJson({
        'question_id': 5, 'type': 'matching', 'text': 'صل', 'points': 2,
        'options': {'column_a': ['الجذر', 'الورقة'], 'column_b': ['صنع الغذاء', 'امتصاص الماء']},
        'answer': {'0': '1', '1': '0'}, 'mark': null, 'ai_mark': {'mark': 1.5, 'reason': 'جزئي'},
      });
      expect(a.answerText, 'الجذر ← امتصاص الماء\nالورقة ← صنع الغذاء');
      expect(a.mark, isNull);
      expect(a.aiMark, 1.5);
      expect(a.aiReason, 'جزئي');
    });

    test('a new test sends only the filled fields', () {
      final json = const NewOnlineTest(examId: 7, title: ' ', groups: [(name: 'رابع 1', classId: 3)], studentFields: ['رقم الجلوس', ' ']).toJson();
      expect(json.containsKey('title'), isFalse);
      expect(json['groups'], [{'name': 'رابع 1', 'class_id': 3}]);
      expect((json['settings'] as Map)['student_fields'], [{'label': 'رقم الجلوس'}]);
    });
  });

  group('create', () {
    test('a class from «فصولي» is added once, and the created test is reported', () async {
      final repo = MockOnlineTestsRepository();
      final classes = MockClassesRepository();
      when(() => repo.create(any())).thenAnswer((_) async => const Right(OnlineTest(id: 11, title: 'x')));
      final cubit = CreateOnlineTestCubit(examId: 7, repository: repo, classes: classes);
      cubit.addGroup('رابع 1', classId: 3);
      cubit.addGroup('رابع 1', classId: 3);
      cubit.addGroup('  ');
      cubit.setTimeLimit('30');
      expect(cubit.state.groups.length, 1);
      await cubit.submit('اختبار');
      expect(cubit.state.createdId, 11);
      final sent = verify(() => repo.create(captureAny())).captured.single as NewOnlineTest;
      expect(sent.timeLimitMinutes, 30);
    });
  });

  group('AI-suggested marks', () {
    late MockOnlineTestsRepository repo;
    late OnlineTestCubit cubit;

    setUp(() {
      repo = MockOnlineTestsRepository();
      cubit = OnlineTestCubit(testId: 3, repository: repo, documents: MockDocumentsRepository(), pollEvery: Duration.zero);
    });

    test('batches are sent until none is left, then the results reload', () async {
      var call = 0;
      when(() => repo.startAiGrading(3)).thenAnswer((_) async {
        call++;
        return Right(AiGradingJob(id: call, status: 'pending', queued: 40, remaining: call == 1 ? 5 : 0));
      });
      when(() => repo.getAiJob(any())).thenAnswer((i) async => Right(AiGradingJob(id: i.positionalArguments.first as int, status: 'done')));
      when(() => repo.getResults(3)).thenAnswer((_) async => Right(_results(suggested: 45)));

      await cubit.suggestMarks();

      expect(call, 2);
      expect(cubit.state.aiDone, 80);
      expect(cubit.state.aiRunning, isFalse);
      expect(cubit.state.results!.aiSuggested, 45);
      expect(cubit.state.message, 'online_tests_ai_done');
      expect(cubit.state.messageIsError, isFalse);
    });

    test('a failed job stops and shows its error', () async {
      when(() => repo.startAiGrading(3)).thenAnswer((_) async => const Right(AiGradingJob(id: 1, status: 'pending', queued: 10, remaining: 0)));
      when(() => repo.getAiJob(1)).thenAnswer((_) async => const Right(AiGradingJob(id: 1, status: 'failed', error: 'تعذر اقتراح الدرجات، حاول مرة أخرى.')));
      when(() => repo.getResults(3)).thenAnswer((_) async => Right(_results(waiting: 10)));

      await cubit.suggestMarks();

      expect(cubit.state.message, 'تعذر اقتراح الدرجات، حاول مرة أخرى.');
      expect(cubit.state.messageIsError, isTrue);
    });

    test('«nothing left» after asking is not an error', () async {
      when(() => repo.startAiGrading(3)).thenAnswer((_) async => const Left(_Failure('لا توجد إجابات تنتظر التصحيح.')));
      when(() => repo.getResults(3)).thenAnswer((_) async => Right(_results()));
      await cubit.suggestMarks();
      expect(cubit.state.messageIsError, isFalse);
    });

    test('«تحليل النتائج» saves a grade analysis document to open', () async {
      final docs = MockDocumentsRepository();
      final c = OnlineTestCubit(testId: 3, repository: repo, documents: docs);
      final input = {'classes': [{'name': 'رابع 1', 'students': [{'name': 'أحمد', 'grade': 8}]}]};
      when(() => repo.gradeAnalysisInput(3)).thenAnswer((_) async => Right((input: input, toReview: 0)));
      when(() => docs.createDocument(type: 'grade_analysis', input: input, status: 'draft'))
          .thenAnswer((_) async => Right(DocumentModel.fromJson({'id': 77, 'type': 'grade_analysis', 'title': 't', 'status': 'draft', 'input': input})));
      await c.toAnalysis();
      expect(c.state.analysisDocumentId, 77);
    });
  });

  group('review', () {
    test('a waiting mark is pre-filled with the suggestion and sent only on save', () async {
      final repo = MockOnlineTestsRepository();
      final detail = SubmissionDetail.fromJson({
        'id': 9, 'group_id': 1, 'student_name': 'أحمد', 'score': 3, 'needs_review': true, 'fields': [],
        'answers': [
          {'question_id': 1, 'type': 'mcq', 'text': 'س', 'points': 1, 'answer': 'أ', 'mark': 1, 'ai_mark': null},
          {'question_id': 2, 'type': 'essay', 'text': 'اشرح', 'points': 4, 'answer': 'لأن', 'mark': null, 'ai_mark': {'mark': 2.5, 'reason': 'ناقص'}},
        ],
      });
      when(() => repo.getSubmission(3, 9)).thenAnswer((_) async => Right(detail));
      when(() => repo.review(3, 9, any())).thenAnswer((_) async => Right(detail));
      final cubit = SubmissionReviewCubit(testId: 3, submissionId: 9, repository: repo);
      await cubit.load();
      expect(cubit.state.marks, {1: '1', 2: '2.5'});

      cubit.setMark(2, '3');
      await cubit.save();
      final sent = verify(() => repo.review(3, 9, captureAny())).captured.single as Map<int, double?>;
      expect(sent, {1: 1.0, 2: 3.0});
      expect(cubit.state.saved, isTrue);
    });
  });
}

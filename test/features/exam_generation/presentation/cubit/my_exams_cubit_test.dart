import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/domain/repositories/exam_repository.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_state.dart';

class MockExamRepository extends Mock implements ExamRepository {}

ExamPaginationEntity _samplePagination({List<ExamListEntity>? items}) {
  final list = items ??
      [
        ExamListEntity(
          id: 1,
          title: 'اختبار تشخيصي — الرياضيات',
          status: 'draft',
          kind: 'diagnostic',
          questionsCount: 10,
          totalPoints: 10,
          createdAt: '2026-10-25',
          updatedAt: '2026-10-25',
        ),
        ExamListEntity(
          id: 2,
          title: 'اختبار الوحدة الأولى',
          status: 'published',
          kind: 'regular',
          questionsCount: 5,
          totalPoints: 10,
          createdAt: '2026-10-25',
          updatedAt: '2026-10-25',
        ),
      ];

  return ExamPaginationEntity(
    currentPage: 1,
    lastPage: 1,
    perPage: 20,
    total: list.length,
    data: list,
  );
}

ExamEntity _sampleExam({int id = 1}) {
  return ExamEntity(
    id: id,
    teacherId: 10,
    title: 'اختبار تشخيصي — الرياضيات',
    status: 'draft',
    totalPoints: 10,
    createdAt: '2026-10-25',
    updatedAt: '2026-10-25',
    questions: const [],
  );
}

void main() {
  late MockExamRepository repository;
  late MyExamsCubit cubit;

  setUp(() {
    repository = MockExamRepository();
    cubit = MyExamsCubit(
      repository,
      searchDebounce: Duration.zero,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('MyExamsCubit', () {
    test('fetchExams emits MyExamsLoading then MyExamsLoaded on success', () async {
      when(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: null,
          search: null,
        ),
      ).thenAnswer((_) async => Right(_samplePagination()));

      final emitted = <MyExamsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.fetchExams(isRefresh: true);
      await Future<void>.delayed(Duration.zero);

      expect(emitted.length, 2);
      expect(emitted[0], isA<MyExamsLoading>());
      expect(emitted[1], isA<MyExamsLoaded>());
      final loaded = emitted[1] as MyExamsLoaded;
      expect(loaded.exams.data.length, 2);
      expect(loaded.selectedTab, 'all');

      await sub.cancel();
    });

    test('fetchExams emits MyExamsError on repository failure', () async {
      when(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: null,
          search: null,
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('network_error')));

      await cubit.fetchExams(isRefresh: true);

      expect(cubit.state, isA<MyExamsError>());
      expect((cubit.state as MyExamsError).message, 'network_error');
      expect(cubit.lastLoaded, isNull);
    });

    test('toggleExpand expands an exam and collapses when tapped again', () async {
      when(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: null,
          search: null,
        ),
      ).thenAnswer((_) async => Right(_samplePagination()));

      await cubit.fetchExams();

      cubit.toggleExpand(1);
      expect((cubit.state as MyExamsLoaded).expandedExamId, 1);

      cubit.toggleExpand(1);
      expect((cubit.state as MyExamsLoaded).expandedExamId, isNull);
    });

    test('changeTab filters by status and ignores duplicate tab selection', () async {
      when(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: 'draft',
          search: null,
        ),
      ).thenAnswer((_) async => Right(_samplePagination()));

      cubit.changeTab('draft');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.selectedTab, 'draft');
      expect((cubit.state as MyExamsLoaded).selectedTab, 'draft');

      cubit.changeTab('draft');
      verify(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: 'draft',
          search: null,
        ),
      ).called(1);
    });

    test('searchExams queries repository after debounce', () async {
      when(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: null,
          search: 'تشخيصي',
        ),
      ).thenAnswer((_) async => Right(_samplePagination()));

      cubit.searchExams('تشخيصي');
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect((cubit.state as MyExamsLoaded).searchQuery, 'تشخيصي');
      verify(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: null,
          search: 'تشخيصي',
        ),
      ).called(1);
    });

    test('publishExam emits success translation key and refreshes exams', () async {
      when(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: null,
          search: null,
        ),
      ).thenAnswer((_) async => Right(_samplePagination()));
      when(() => repository.publishExam(1))
          .thenAnswer((_) async => Right(_sampleExam()));

      await cubit.fetchExams();

      final emitted = <MyExamsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.publishExam(1);
      await Future<void>.delayed(Duration.zero);

      expect(
        emitted.whereType<MyExamsActionSuccess>().single.message,
        'exam_published_success',
      );
      expect(cubit.state, isA<MyExamsLoaded>());

      await sub.cancel();
    });

    test('deleteExam emits error and restores loaded state on failure', () async {
      when(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: null,
          search: null,
        ),
      ).thenAnswer((_) async => Right(_samplePagination()));
      when(() => repository.deleteExam(1))
          .thenAnswer((_) async => const Left(ServerFailure('generic_error')));

      await cubit.fetchExams();

      final emitted = <MyExamsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.deleteExam(1);
      await Future<void>.delayed(Duration.zero);

      expect(
        emitted.whereType<MyExamsActionError>().single.message,
        'generic_error',
      );
      expect(cubit.state, isA<MyExamsLoaded>());

      await sub.cancel();
    });

    test('openExamPreview emits MyExamsPreviewReady then restores loaded state', () async {
      when(
        () => repository.getMyExams(
          page: 1,
          perPage: 20,
          status: null,
          search: null,
        ),
      ).thenAnswer((_) async => Right(_samplePagination()));
      when(() => repository.getExam(1))
          .thenAnswer((_) async => Right(_sampleExam(id: 1)));

      await cubit.fetchExams();

      final emitted = <MyExamsState>[];
      final sub = cubit.stream.listen(emitted.add);

      await cubit.openExamPreview(1);
      await Future<void>.delayed(Duration.zero);

      expect(emitted.first, isA<MyExamsLoaded>());
      expect((emitted.first as MyExamsLoaded).isPreviewLoading, isTrue);
      expect(emitted.whereType<MyExamsPreviewReady>().single.exam.id, 1);
      expect(cubit.state, isA<MyExamsLoaded>());
      expect((cubit.state as MyExamsLoaded).isPreviewLoading, isFalse);

      await sub.cancel();
    });
  });
}

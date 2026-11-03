import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/models/lab_filters_model.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';
import 'package:moean/features/lab/presentation/cubit/lab_library_cubit.dart';

class MockLabRepository extends Mock implements LabRepository {}

void main() {
  late MockLabRepository mockRepo;
  late LabLibraryCubit cubit;

  const testExp1 = LabExperimentModel(
    key: 'ohm',
    name: 'قانون أوم',
    plays: 50,
  );
  const testExp2 = LabExperimentModel(
    key: 'density',
    name: 'الكثافة',
    plays: 30,
  );

  const testPage1 = LabExperimentsPage(
    items: [testExp1],
    currentPage: 1,
    lastPage: 2,
    total: 2,
  );

  const testPage2 = LabExperimentsPage(
    items: [testExp2],
    currentPage: 2,
    lastPage: 2,
    total: 2,
  );

  const testFilters = LabFiltersModel(
    stages: [
      LabStageModel(
        id: 1,
        name: 'المرحلة الثانوية',
        grades: [
          LabGradeModel(
            id: 10,
            name: 'الأول الثانوي',
            subjects: [
              LabSubjectModel(id: 100, name: 'الفيزياء 1'),
            ],
          ),
        ],
      ),
    ],
    subjectGroups: [
      LabSubjectGroupModel(key: 'physics', name: 'الفيزياء'),
    ],
    totalExperiments: 10,
  );

  setUp(() {
    mockRepo = MockLabRepository();
    cubit = LabLibraryCubit(
      labRepository: mockRepo,
      searchDebounce: Duration.zero,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('LabLibraryCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.status, LabLibraryStatus.initial);
      expect(cubit.state.experiments, isEmpty);
      expect(cubit.state.sort, 'popular');
      expect(cubit.state.hasActiveFilters, isFalse);
    });

    test('init calls load and loadFilters', () async {
      when(() => mockRepo.getFilters()).thenAnswer(
        (_) async => const Right(testFilters),
      );
      when(() => mockRepo.getExperiments(
            page: any(named: 'page'),
            search: any(named: 'search'),
            stageId: any(named: 'stageId'),
            gradeId: any(named: 'gradeId'),
            subjectId: any(named: 'subjectId'),
            subjectGroup: any(named: 'subjectGroup'),
            lessonId: any(named: 'lessonId'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => const Right(testPage1));

      await cubit.init();

      expect(cubit.state.status, LabLibraryStatus.success);
      expect(cubit.state.experiments, [testExp1]);
      expect(cubit.state.filters, testFilters);
      expect(cubit.state.hasMore, isTrue);
    });

    test('load failure updates state with failure and error message', () async {
      when(() => mockRepo.getExperiments(
            page: any(named: 'page'),
            search: any(named: 'search'),
            stageId: any(named: 'stageId'),
            gradeId: any(named: 'gradeId'),
            subjectId: any(named: 'subjectId'),
            subjectGroup: any(named: 'subjectGroup'),
            lessonId: any(named: 'lessonId'),
            sort: any(named: 'sort'),
          )).thenAnswer(
        (_) async => const Left(ServerFailure('failed_to_fetch')),
      );

      await cubit.load();

      expect(cubit.state.status, LabLibraryStatus.failure);
      expect(cubit.state.errorMessage, 'failed_to_fetch');
      expect(cubit.state.experiments, isEmpty);
    });

    test('loadMore appends more experiments and updates page', () async {
      when(() => mockRepo.getExperiments(
            page: 1,
            search: any(named: 'search'),
            stageId: any(named: 'stageId'),
            gradeId: any(named: 'gradeId'),
            subjectId: any(named: 'subjectId'),
            subjectGroup: any(named: 'subjectGroup'),
            lessonId: any(named: 'lessonId'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => const Right(testPage1));

      await cubit.load();

      when(() => mockRepo.getExperiments(
            page: 2,
            search: any(named: 'search'),
            stageId: any(named: 'stageId'),
            gradeId: any(named: 'gradeId'),
            subjectId: any(named: 'subjectId'),
            subjectGroup: any(named: 'subjectGroup'),
            lessonId: any(named: 'lessonId'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => const Right(testPage2));

      await cubit.loadMore();

      expect(cubit.state.experiments, [testExp1, testExp2]);
      expect(cubit.state.page, 2);
      expect(cubit.state.hasMore, isFalse);
    });

    test('setSort changes sort and reloads', () async {
      when(() => mockRepo.getExperiments(
            page: any(named: 'page'),
            search: any(named: 'search'),
            stageId: any(named: 'stageId'),
            gradeId: any(named: 'gradeId'),
            subjectId: any(named: 'subjectId'),
            subjectGroup: any(named: 'subjectGroup'),
            lessonId: any(named: 'lessonId'),
            sort: 'name',
          )).thenAnswer((_) async => const Right(testPage1));

      cubit.setSort('name');
      await pumpEventQueue();

      expect(cubit.state.sort, 'name');
    });

    test('filtering by stage, grade, subject and clearing filters', () async {
      when(() => mockRepo.getExperiments(
            page: any(named: 'page'),
            search: any(named: 'search'),
            stageId: any(named: 'stageId'),
            gradeId: any(named: 'gradeId'),
            subjectId: any(named: 'subjectId'),
            subjectGroup: any(named: 'subjectGroup'),
            lessonId: any(named: 'lessonId'),
            sort: any(named: 'sort'),
          )).thenAnswer((_) async => const Right(testPage1));

      cubit.setStage(1);
      await pumpEventQueue();
      expect(cubit.state.selectedStageId, 1);
      expect(cubit.state.hasActiveFilters, isTrue);

      cubit.setGrade(10);
      await pumpEventQueue();
      expect(cubit.state.selectedGradeId, 10);

      cubit.setSubject(100);
      await pumpEventQueue();
      expect(cubit.state.selectedSubjectId, 100);

      cubit.clearFilters();
      await pumpEventQueue();
      expect(cubit.state.selectedStageId, isNull);
      expect(cubit.state.selectedGradeId, isNull);
      expect(cubit.state.selectedSubjectId, isNull);
      expect(cubit.state.hasActiveFilters, isFalse);
    });
  });
}

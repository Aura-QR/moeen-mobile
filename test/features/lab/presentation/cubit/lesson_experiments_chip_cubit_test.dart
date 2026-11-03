import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';
import 'package:moean/features/lab/presentation/cubit/lesson_experiments_chip_cubit.dart';

class MockLabRepository extends Mock implements LabRepository {}

void main() {
  late MockLabRepository mockRepo;
  late LessonExperimentsChipCubit cubit;

  setUp(() {
    mockRepo = MockLabRepository();
    cubit = LessonExperimentsChipCubit(labRepository: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('LessonExperimentsChipCubit', () {
    test('loadForLesson with null or <= 0 does not call repository', () async {
      await cubit.loadForLesson(null);
      await cubit.loadForLesson(0);

      expect(cubit.state.count, 0);
      verifyZeroInteractions(mockRepo);
    });

    test('loadForLesson emits count when repository returns items', () async {
      when(() => mockRepo.getLessonExperiments(42)).thenAnswer(
        (_) async => const Right([
          LabExperimentModel(key: 'ohm', name: 'قانون أوم'),
          LabExperimentModel(key: 'density', name: 'الكثافة'),
        ]),
      );

      await cubit.loadForLesson(42);

      expect(cubit.state.lessonId, 42);
      expect(cubit.state.count, 2);
      expect(cubit.state.isLoading, isFalse);
    });

    test('loadForLesson emits 0 on failure', () async {
      when(() => mockRepo.getLessonExperiments(99)).thenAnswer(
        (_) async => const Left(ServerFailure('error')),
      );

      await cubit.loadForLesson(99);

      expect(cubit.state.lessonId, 99);
      expect(cubit.state.count, 0);
      expect(cubit.state.isLoading, isFalse);
    });
  });
}

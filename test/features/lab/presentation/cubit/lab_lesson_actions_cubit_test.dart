import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/lab/data/models/lab_create_experiment_input.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';
import 'package:moean/features/lab/presentation/cubit/lab_lesson_actions_cubit.dart';

class MockLabRepository extends Mock implements LabRepository {}

void main() {
  late MockLabRepository mockRepo;
  late LabLessonActionsCubit cubit;

  const validInput = LabCreateExperimentInput(
    name: 'حساب الوزن على القمر',
    display: 'bars',
    observe: 'الوزن على القمر يعادل سدس الوزن على الأرض',
    lessonId: 3259,
    variables: [
      LabVariableInput(symbol: 'a', label: 'الكتلة', unit: 'kg', min: 0, max: 100, defaultValue: 50),
    ],
    readings: [
      LabReadingInput(label: 'الوزن', unit: 'N', formula: 'a × 1.62'),
    ],
  );

  setUpAll(() {
    registerFallbackValue(validInput);
  });

  setUp(() {
    mockRepo = MockLabRepository();
    cubit = LabLessonActionsCubit(labRepository: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('LabLessonActionsCubit', () {
    test('submitRequest with empty message returns false', () async {
      final result = await cubit.submitRequest(lessonId: 3259, message: '  ');
      expect(result, isFalse);
      expect(cubit.state.feedback?.message, 'lab_request_empty_error');
      verifyNever(
        () => mockRepo.requestExperiment(
          lessonId: any(named: 'lessonId'),
          message: any(named: 'message'),
        ),
      );
    });

    test('submitRequest success returns true and emits success feedback', () async {
      when(
        () => mockRepo.requestExperiment(
          lessonId: 3259,
          message: 'نحتاج تجربة لكبلر',
        ),
      ).thenAnswer((_) async => const Right(unit));

      final result = await cubit.submitRequest(
        lessonId: 3259,
        message: 'نحتاج تجربة لكبلر',
      );

      expect(result, isTrue);
      expect(cubit.state.feedback?.message, 'lab_request_success');
      expect(cubit.state.feedback?.isError, isFalse);
    });

    test('submitCreateExperiment validates min < max', () async {
      const invalidMinMax = LabCreateExperimentInput(
        name: 'تجربة',
        variables: [
          LabVariableInput(symbol: 'a', label: 'الكتلة', min: 100, max: 10),
        ],
        readings: [
          LabReadingInput(label: 'الوزن', formula: 'a * 2'),
        ],
      );

      final created = await cubit.submitCreateExperiment(invalidMinMax);
      expect(created, isNull);
      expect(cubit.state.feedback?.message, 'lab_create_minmax_error');
      verifyNever(() => mockRepo.createExperiment(any()));
    });

    test('submitCreateExperiment rejects unknown variable symbol in formula', () async {
      const invalidFormula = LabCreateExperimentInput(
        name: 'تجربة',
        variables: [
          LabVariableInput(symbol: 'a', label: 'الكتلة', min: 1, max: 100),
        ],
        readings: [
          LabReadingInput(label: 'الوزن', formula: 'k'),
        ],
      );

      final created = await cubit.submitCreateExperiment(invalidFormula);
      expect(created, isNull);
      expect(cubit.state.feedback?.message, 'lab_create_formula_error');
      verifyNever(() => mockRepo.createExperiment(any()));
    });

    test('normalizes ×, ÷, √ and multi-variable formulas (a, b)', () async {
      const multiVarInput = LabCreateExperimentInput(
        name: 'قانون أوم',
        variables: [
          LabVariableInput(symbol: 'a', label: 'الجهد', min: 0, max: 24, defaultValue: 12),
          LabVariableInput(symbol: 'b', label: 'المقاومة', min: 1, max: 100, defaultValue: 10),
        ],
        readings: [
          LabReadingInput(label: 'التيار', formula: 'a ÷ b + √(a)'),
        ],
      );
      expect(multiVarInput.readings.first.normalizedFormula, 'a / b + sqrt(a)');

      const createdModel = LabExperimentModel(
        key: 'c_8f3k29ab',
        name: 'قانون أوم',
        source: 'community',
      );
      when(() => mockRepo.createExperiment(any()))
          .thenAnswer((_) async => const Right(createdModel));

      final created = await cubit.submitCreateExperiment(multiVarInput);
      expect(created?.key, 'c_8f3k29ab');
    });

    test('submitCreateExperiment success returns created experiment', () async {
      const createdModel = LabExperimentModel(
        key: 'c_8f3k29ab',
        name: 'حساب الوزن على القمر',
        source: 'community',
      );
      when(() => mockRepo.createExperiment(any()))
          .thenAnswer((_) async => const Right(createdModel));

      final created = await cubit.submitCreateExperiment(validInput);

      expect(created, isNotNull);
      expect(created?.key, 'c_8f3k29ab');
      expect(cubit.state.createdExperiment?.key, 'c_8f3k29ab');
      expect(cubit.state.feedback?.message, 'lab_create_success');
    });

    test('submitCreateExperiment failure emits error feedback', () async {
      when(() => mockRepo.createExperiment(any()))
          .thenAnswer((_) async => const Left(ServerFailure('formula_invalid')));

      final created = await cubit.submitCreateExperiment(validInput);

      expect(created, isNull);
      expect(cubit.state.feedback?.message, 'formula_invalid');
      expect(cubit.state.feedback?.isError, isTrue);
    });
  });
}

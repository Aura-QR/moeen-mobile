import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/lab/data/repositories/lab_repository.dart';
import 'package:moean/features/lab/presentation/cubit/lab_experiment_cubit.dart';

class MockLabRepository extends Mock implements LabRepository {}

void main() {
  late MockLabRepository mockRepo;
  late LabExperimentCubit cubit;

  setUp(() {
    mockRepo = MockLabRepository();
    cubit = LabExperimentCubit(
      labRepository: mockRepo,
      experimentKey: 'ohm',
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('LabExperimentCubit', () {
    test('initial state has loading webViewStatus', () {
      expect(cubit.state.webViewStatus, LabWebViewStatus.loading);
      expect(cubit.state.isReporting, isFalse);
      expect(cubit.state.reportSuccess, isFalse);
    });

    test('onWebViewReady triggers playExperiment only once', () async {
      when(() => mockRepo.playExperiment('ohm')).thenAnswer(
        (_) async => const Right(unit),
      );

      cubit.onWebViewReady();
      expect(cubit.state.webViewStatus, LabWebViewStatus.ready);

      // Calling onWebViewReady again should not call playExperiment again
      cubit.onWebViewReady();

      verify(() => mockRepo.playExperiment('ohm')).called(1);
    });

    test('onWebViewError sets error status, retryLoad resets to loading', () {
      cubit.onWebViewError();
      expect(cubit.state.webViewStatus, LabWebViewStatus.error);

      cubit.retryLoad();
      expect(cubit.state.webViewStatus, LabWebViewStatus.loading);
    });

    test('reportMistake with empty text returns false with feedback', () async {
      final success = await cubit.reportMistake('   ');
      expect(success, isFalse);
      expect(cubit.state.feedback?.message, 'lab_report_empty_error');
      verifyNever(() => mockRepo.reportMistake(any(), any()));
    });

    test('reportMistake success returns true and updates state', () async {
      when(() => mockRepo.reportMistake('ohm', 'ملاحظة على القانون'))
          .thenAnswer((_) async => const Right(unit));

      final success = await cubit.reportMistake('ملاحظة على القانون');

      expect(success, isTrue);
      expect(cubit.state.reportSuccess, isTrue);
      expect(cubit.state.feedback?.message, 'lab_report_success');
      verify(() => mockRepo.reportMistake('ohm', 'ملاحظة على القانون')).called(1);
    });

    test('reportMistake failure returns false and updates state with error', () async {
      when(() => mockRepo.reportMistake('ohm', 'خطأ في التجربة'))
          .thenAnswer((_) async => const Left(ServerFailure('server_error')));

      final success = await cubit.reportMistake('خطأ في التجربة');

      expect(success, isFalse);
      expect(cubit.state.reportSuccess, isFalse);
      expect(cubit.state.reportError, 'server_error');
    });
  });
}

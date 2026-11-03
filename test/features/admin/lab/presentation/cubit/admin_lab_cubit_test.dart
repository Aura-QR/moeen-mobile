import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/features/admin/lab/data/models/admin_lab_models.dart';
import 'package:moean/features/admin/lab/data/repositories/admin_lab_repository.dart';
import 'package:moean/features/admin/lab/presentation/cubit/admin_lab_cubit.dart';

class MockAdminLabRepository extends Mock implements AdminLabRepository {}

void main() {
  late MockAdminLabRepository mockRepo;
  late AdminLabCubit cubit;

  setUp(() {
    mockRepo = MockAdminLabRepository();
    cubit = AdminLabCubit(adminLabRepository: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('AdminLabCubit', () {
    const testExperiment = AdminLabExperimentModel(
      key: 'c_test',
      name: 'تجربة المجتمع',
      source: 'community',
      approved: false,
      status: 'published',
      featured: false,
    );

    const testReport = AdminLabMistakeReportModel(
      id: 1,
      message: 'بلاغ خطأ',
      status: 'open',
    );

    const testRequest = AdminLabRequestModel(
      id: 1,
      message: 'طلب تجربة',
      status: 'open',
    );

    test('initial state defaults are correct', () {
      expect(cubit.state.currentTab, 0);
      expect(cubit.state.experiments, isEmpty);
      expect(cubit.state.reports, isEmpty);
      expect(cubit.state.requests, isEmpty);
      expect(cubit.state.isLoadingExperiments, isFalse);
    });

    test('init calls getExperiments, getReports, getRequests', () async {
      when(() => mockRepo.getExperiments(
            status: any(named: 'status'),
            source: any(named: 'source'),
            featured: any(named: 'featured'),
            hasReports: any(named: 'hasReports'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => const Right([testExperiment]));

      when(() => mockRepo.getReports(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([testReport]));

      when(() => mockRepo.getRequests(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([testRequest]));

      await cubit.init();

      expect(cubit.state.experiments, [testExperiment]);
      expect(cubit.state.reports, [testReport]);
      expect(cubit.state.requests, [testRequest]);
    });

    test('setTab switches tab index', () {
      cubit.setTab(1);
      expect(cubit.state.currentTab, 1);
      cubit.setTab(2);
      expect(cubit.state.currentTab, 2);
    });

    test('toggleApproveExperiment updates experiment approval in list', () async {
      when(() => mockRepo.getExperiments(
            status: any(named: 'status'),
            source: any(named: 'source'),
            featured: any(named: 'featured'),
            hasReports: any(named: 'hasReports'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => const Right([testExperiment]));

      when(() => mockRepo.getReports(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([]));
      when(() => mockRepo.getRequests(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([]));

      await cubit.init();

      when(() => mockRepo.updateExperiment('c_test', approve: true))
          .thenAnswer((_) async => const Right(unit));

      await cubit.toggleApproveExperiment(testExperiment);

      expect(cubit.state.experiments.first.approved, isTrue);
      expect(cubit.state.feedback?.isError, isFalse);
    });

    test('togglePublishExperiment hides published experiment', () async {
      when(() => mockRepo.getExperiments(
            status: any(named: 'status'),
            source: any(named: 'source'),
            featured: any(named: 'featured'),
            hasReports: any(named: 'hasReports'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => const Right([testExperiment]));

      when(() => mockRepo.getReports(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([]));
      when(() => mockRepo.getRequests(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([]));

      await cubit.init();

      when(() => mockRepo.updateExperiment('c_test', status: 'hidden'))
          .thenAnswer((_) async => const Right(unit));

      await cubit.togglePublishExperiment(testExperiment);

      expect(cubit.state.experiments.first.isPublished, isFalse);
    });

    test('toggleReportStatus updates report status to done', () async {
      when(() => mockRepo.getExperiments(
            status: any(named: 'status'),
            source: any(named: 'source'),
            featured: any(named: 'featured'),
            hasReports: any(named: 'hasReports'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => const Right([]));

      when(() => mockRepo.getReports(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([testReport]));
      when(() => mockRepo.getRequests(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([]));

      await cubit.init();

      when(() => mockRepo.updateReportStatus(1, 'done'))
          .thenAnswer((_) async => const Right(unit));

      await cubit.toggleReportStatus(testReport);

      expect(cubit.state.reports.first.isOpen, isFalse);
    });

    test('toggleRequestStatus updates request status to done', () async {
      when(() => mockRepo.getExperiments(
            status: any(named: 'status'),
            source: any(named: 'source'),
            featured: any(named: 'featured'),
            hasReports: any(named: 'hasReports'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => const Right([]));

      when(() => mockRepo.getReports(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([]));
      when(() => mockRepo.getRequests(status: any(named: 'status')))
          .thenAnswer((_) async => const Right([testRequest]));

      await cubit.init();

      when(() => mockRepo.updateRequestStatus(1, 'done'))
          .thenAnswer((_) async => const Right(unit));

      await cubit.toggleRequestStatus(testRequest);

      expect(cubit.state.requests.first.isOpen, isFalse);
    });

    test('onSearchChanged passes search query to getExperiments', () async {
      final fastCubit = AdminLabCubit(
        adminLabRepository: mockRepo,
        searchDebounce: Duration.zero,
      );
      when(() => mockRepo.getExperiments(
            status: any(named: 'status'),
            source: any(named: 'source'),
            featured: any(named: 'featured'),
            hasReports: any(named: 'hasReports'),
            search: 'أوم',
          )).thenAnswer((_) async => const Right([testExperiment]));

      fastCubit.searchController.text = 'أوم';
      fastCubit.onSearchChanged('أوم');
      await pumpEventQueue();

      expect(fastCubit.state.experiments, [testExperiment]);
      verify(() => mockRepo.getExperiments(search: 'أوم')).called(1);
      await fastCubit.close();
    });
  });
}

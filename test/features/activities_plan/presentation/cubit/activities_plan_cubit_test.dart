import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/activities_plan/data/models/activities_catalogue_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_program_models.dart';
import 'package:moean/features/activities_plan/data/repositories/activities_repository.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';

class MockActivitiesRepository extends Mock implements ActivitiesRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

const _catalogue = ActivitiesCatalogueModel(
  stages: [ActivitiesStageModel(key: 'primary', label: 'ابتدائي', name: 'المرحلة الابتدائية')],
  domains: [
    ActivitiesDomainModel(key: 'citizenship', label: 'المواطنة والحياة'),
    ActivitiesDomainModel(key: 'sports_health', label: 'الرياضة والصحة'),
  ],
  bands: [
    ActivitiesBandModel(key: 'primary_early', label: 'الصفوف الأولية', periodsPerWeek: 3),
    ActivitiesBandModel(key: 'secondary', label: 'المرحلة الثانوية', periodsPerWeek: 2),
  ],
  programDomains: [
    ActivitiesProgramDomainModel(key: 'citizenship', label: 'المواطنة والحياة', programs: [
      ActivitiesProgramModel(key: 'volunteering', label: 'التطوع الطلابي', periods: {'primary_early': 4, 'secondary': 6}),
      ActivitiesProgramModel(key: 'values', label: 'قيمنا حياة', periods: {'primary_early': 0, 'secondary': 12}),
    ]),
    ActivitiesProgramDomainModel(key: 'sports', label: 'الرياضة والصحة'),
  ],
  occasionsDomain: ActivitiesDomainModel(key: 'occasions', label: 'الأيام والمناسبات'),
  extracurricular: [ActivitiesExtracurricularModel(key: 'success_journey', label: 'رحلة نجاح')],
  officialDays: [
    ActivitiesOfficialDayModel(key: 'national_day', name: 'اليوم الوطني', periods: {'primary_early': 4, 'secondary': 4}),
    ActivitiesOfficialDayModel(key: 'children_day', name: 'اليوم العالمي للطفل', periods: {'primary_early': 2, 'secondary': 0}),
  ],
  einUrl: 'https://www.ien.edu.sa/#/studentactivities',
);

const _grid = ActivitiesGridModel(
  term: 1,
  region: 'general',
  columns: [
    ActivitiesColumnModel(key: 'citizenship', label: 'المواطنة والحياة'),
    ActivitiesColumnModel(key: ActivitiesColumns.occasion, label: 'المناسبات'),
  ],
  weeks: [
    ActivitiesWeekModel(
      week: 3,
      type: ActivitiesWeekType.teaching,
      cells: {'citizenship': 'إذاعة مدرسية', 'occasion': 'اليوم الوطني'},
    ),
  ],
);

const _officialGrid = ActivitiesGridModel(
  term: 1,
  region: 'general',
  columns: [
    ActivitiesColumnModel(key: ActivitiesColumns.domain, label: 'المجال'),
    ActivitiesColumnModel(key: ActivitiesColumns.program, label: 'البرنامج'),
    ActivitiesColumnModel(key: ActivitiesColumns.periods, label: 'الحصص'),
    ActivitiesColumnModel(key: ActivitiesColumns.extracurricular, label: 'الفترات اللاصفية'),
    ActivitiesColumnModel(key: ActivitiesColumns.occasion, label: 'المناسبات'),
  ],
  weeks: [
    ActivitiesWeekModel(week: 1, type: ActivitiesWeekType.teaching, cells: {
      'domain': 'citizenship',
      'program': 'التطوع الطلابي',
      'periods': '3',
      'extracurricular': '',
      'occasion': '',
    }),
    ActivitiesWeekModel(week: 2, type: ActivitiesWeekType.teaching, cells: {
      'domain': 'citizenship',
      'program': 'التطوع الطلابي (تابع)',
      'periods': '1',
      'extracurricular': '',
      'occasion': '',
    }),
    ActivitiesWeekModel(week: 3, type: ActivitiesWeekType.teaching, cells: {
      'domain': 'occasions',
      'program': 'اليوم الوطني',
      'periods': '4',
      'extracurricular': '',
      'occasion': 'اليوم الوطني',
    }),
    ActivitiesWeekModel(week: null, type: ActivitiesWeekType.holiday, title: 'إجازة الخريف'),
    ActivitiesWeekModel(week: 18, type: ActivitiesWeekType.exam, cells: {'occasion': ''}),
  ],
  summary: ActivitiesSummaryModel(
    domains: [ActivitiesSummaryDomainModel(key: 'citizenship', label: 'المواطنة والحياة', periods: 4)],
    total: 8,
    target: 54,
  ),
);

DocumentModel _saved(int id, {Map<String, dynamic> input = const {}}) => DocumentModel(
      id: id,
      type: DocumentTypes.activitiesPlan,
      title: 'خطة النشاط الطلابي',
      status: DocumentStatus.draft,
      input: input,
    );

void main() {
  late MockActivitiesRepository activities;
  late MockDocumentsRepository documents;

  ActivitiesPlanCubit build({int? documentId}) => ActivitiesPlanCubit(
        documentId: documentId,
        activitiesRepository: activities,
        documentsRepository: documents,
        filePicker: MockDeviceFilePicker(),
      );

  /// A plan saved before the official layout: no `layout` in its input.
  Future<ActivitiesPlanCubit> loadLegacy([Map<String, dynamic> input = const {'term': 1}]) async {
    when(() => documents.getDocument(30)).thenAnswer((_) async => Right(_saved(30, input: input)));
    final cubit = build(documentId: 30);
    await cubit.load();
    return cubit;
  }

  void stubGrid([Future<Either<Failure, ActivitiesGridModel>> Function()? answer]) => when(
        () => activities.getGrid(
          stage: any(named: 'stage'),
          term: any(named: 'term'),
          domains: any(named: 'domains'),
          region: any(named: 'region'),
        ),
      ).thenAnswer((_) => answer?.call() ?? Future.value(const Right(_grid)));

  void stubOfficialGrid([Future<Either<Failure, ActivitiesGridModel>> Function()? answer]) => when(
        () => activities.getOfficialGrid(
          band: any(named: 'band'),
          term: any(named: 'term'),
          periodsPerWeek: any(named: 'periodsPerWeek'),
          region: any(named: 'region'),
        ),
      ).thenAnswer((_) => answer?.call() ?? Future.value(const Right(_officialGrid)));

  Map<String, dynamic> capturedCreateInput() => verify(
        () => documents.createDocument(
          type: DocumentTypes.activitiesPlan,
          input: captureAny(named: 'input'),
          status: any(named: 'status'),
        ),
      ).captured.single as Map<String, dynamic>;

  Map<String, dynamic> capturedUpdateInput() => verify(
        () => documents.updateDocument(30, captureAny(), status: any(named: 'status')),
      ).captured.single as Map<String, dynamic>;

  setUp(() {
    activities = MockActivitiesRepository();
    documents = MockDocumentsRepository();
    when(() => activities.getCatalogue()).thenAnswer((_) async => const Right(_catalogue));
    when(() => documents.getDefaults()).thenAnswer((_) async => const Right(DocumentDefaultsModel()));
    when(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(30)));
    when(() => documents.updateDocument(any(), any(), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(30)));
    stubGrid();
    stubOfficialGrid();
  });

  group('official layout (every new plan)', () {
    test('a new plan is official, and no grid loads until a band is chosen', () async {
      final cubit = build();
      await cubit.load();

      expect(cubit.state.status, ActivitiesPlanStatus.success);
      expect(cubit.state.isOfficial, isTrue);
      expect(cubit.state.catalogue.bands, hasLength(2));
      expect(cubit.state.gridStatus, ActivitiesGridStatus.idle);
      verifyNever(() => activities.getOfficialGrid(
            band: any(named: 'band'),
            term: any(named: 'term'),
            periodsPerWeek: any(named: 'periodsPerWeek'),
            region: any(named: 'region'),
          ));
      await cubit.close();
    });

    test('choosing a band prefills its periods per week and loads the grid', () async {
      final cubit = build();
      await cubit.load();
      cubit.setBand('primary_early');
      await pumpEventQueue();

      expect(cubit.state.effectivePeriodsPerWeek, 3);
      expect(cubit.state.gridStatus, ActivitiesGridStatus.success);
      verify(() => activities.getOfficialGrid(band: 'primary_early', term: 1, periodsPerWeek: 3, region: null)).called(1);

      cubit.setBand('secondary');
      expect(cubit.state.effectivePeriodsPerWeek, 2);
      cubit.setPeriodsPerWeek(9);
      expect(cubit.state.effectivePeriodsPerWeek, 6);
      cubit.setPeriodsPerWeek(0);
      expect(cubit.state.effectivePeriodsPerWeek, 1);
      await cubit.close();
    });

    test('picking an approved program prefills its periods; a local one leaves them', () async {
      final cubit = build();
      await cubit.load();
      cubit.setBand('primary_early');
      await pumpEventQueue();

      cubit.setProgram(1, 'الخط العربي', periods: 4);
      expect(cubit.state.cells[1], {'program': 'الخط العربي', 'periods': '4'});

      cubit.setProgram(1, 'برنامج المدرسة');
      expect(cubit.state.cells[1], {'program': 'برنامج المدرسة', 'periods': '4'});
      await cubit.close();
    });

    test('periods are a whole number from 0 to 20, else empty', () async {
      final cubit = build();
      await cubit.load();
      cubit.setBand('primary_early');
      await pumpEventQueue();

      cubit.setPeriods(1, ' 7 ');
      expect(cubit.state.cells[1]?['periods'], '7');
      cubit.setPeriods(1, '45');
      expect(cubit.state.cells[1]?['periods'], '20');
      cubit.setPeriods(1, 'abc');
      expect(cubit.state.cells[1]?['periods'], '');
      await cubit.close();
    });

    test('the summary follows the teacher\'s changes over the suggestions', () async {
      final cubit = build();
      await cubit.load();
      cubit.setBand('primary_early');
      await pumpEventQueue();

      var summary = cubit.state.officialSummary!;
      expect(summary.domains.firstWhere((d) => d.key == 'citizenship').periods, 4);
      expect(summary.domains.firstWhere((d) => d.key == 'occasions').periods, 4);
      expect(summary.domains.firstWhere((d) => d.key == 'sports').periods, 0);
      expect(summary.total, 8);
      expect(summary.target, 54);

      cubit.setCell(2, ActivitiesColumns.domain, 'sports');
      cubit.setPeriods(1, '5');
      summary = cubit.state.officialSummary!;
      expect(summary.domains.firstWhere((d) => d.key == 'citizenship').periods, 5);
      expect(summary.domains.firstWhere((d) => d.key == 'sports').periods, 1);
      expect(summary.total, 10);
      await cubit.close();
    });

    test('save needs a band', () async {
      final cubit = build();
      await cubit.load();
      await cubit.save();

      expect(cubit.state.feedback?.message, 'activities_plan_band_required');
      verifyNever(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')));
      await cubit.close();
    });

    test('save sends layout, band and periods, only the changed cells, and no stage or domains', () async {
      final cubit = build();
      await cubit.load();
      cubit.setBand('primary_early');
      cubit.setPeriodsPerWeek(2);
      await pumpEventQueue();
      cubit.setProgram(1, 'الخط العربي', periods: 4);
      cubit.setCell(1, ActivitiesColumns.extracurricular, 'success_journey');
      cubit.setCell(3, ActivitiesColumns.occasion, '');
      await cubit.save();

      final input = capturedCreateInput();
      expect(input['layout'], 'official');
      expect(input['band'], 'primary_early');
      expect(input['periods_per_week'], 2);
      expect(input.containsKey('stage'), isFalse);
      expect(input.containsKey('domains'), isFalse);
      expect(input['cells'], {
        '1': {'program': 'الخط العربي', 'periods': '4', 'extracurricular': 'success_journey'},
        '3': {'occasion': ''},
      });
      await cubit.close();
    });

    test('reopening an official plan restores its band and loads its grid', () async {
      when(() => documents.getDocument(30)).thenAnswer((_) async => Right(_saved(30, input: const {
            'layout': 'official',
            'band': 'secondary',
            'periods_per_week': 4,
            'term': 2,
            'cells': {
              '1': {'program': 'الخط العربي'},
            },
          })));
      final cubit = build(documentId: 30);
      await cubit.load();

      expect(cubit.state.isOfficial, isTrue);
      verify(() => activities.getOfficialGrid(band: 'secondary', term: 2, periodsPerWeek: 4, region: null)).called(1);
      expect(cubit.state.textOf(cubit.state.grid!.weeks.first, 'program'), 'الخط العربي');
      await cubit.close();
    });
  });

  group('old layout (plans saved without a layout)', () {
    test('opens in the old form, with no grid until a stage and a domain are chosen', () async {
      final cubit = await loadLegacy();

      expect(cubit.state.isLegacy, isTrue);
      expect(cubit.state.gridStatus, ActivitiesGridStatus.idle);
      verifyNever(() => activities.getGrid(
            stage: any(named: 'stage'),
            term: any(named: 'term'),
            domains: any(named: 'domains'),
            region: any(named: 'region'),
          ));
      expect(cubit.state.officialSummary, isNull);
      await cubit.close();
    });

    test('choosing a stage and domains loads the grid, columns in the picked order', () async {
      final cubit = await loadLegacy();
      cubit.setStage('primary');
      cubit.toggleDomain('sports_health');
      cubit.toggleDomain('citizenship');
      await pumpEventQueue();

      expect(cubit.state.gridStatus, ActivitiesGridStatus.success);
      verify(() => activities.getGrid(stage: 'primary', term: 1, domains: ['sports_health', 'citizenship'], region: null))
          .called(1);

      cubit.reorderDomain(1, 0);
      cubit.toggleDomain('sports_health');
      expect(cubit.state.domains, ['citizenship']);
      await cubit.close();
    });

    test('only the latest grid request lands', () async {
      final slow = Completer<Either<Failure, ActivitiesGridModel>>();
      final cubit = await loadLegacy();
      stubGrid(() => slow.future);
      cubit.setStage('primary');
      cubit.toggleDomain('citizenship');
      stubGrid(() async => const Left(ServerFailure('generic_error')));
      cubit.setTerm(2);
      await pumpEventQueue();
      slow.complete(const Right(_grid));
      await pumpEventQueue();

      expect(cubit.state.gridStatus, ActivitiesGridStatus.failure);
      expect(cubit.state.grid, isNull);
      await cubit.close();
    });

    test('a changed cell wins; the suggestion text or a reset clears the change', () async {
      final cubit = await loadLegacy();
      cubit.setStage('primary');
      cubit.toggleDomain('citizenship');
      await pumpEventQueue();
      final week = cubit.state.grid!.weeks.single;

      cubit.setCell(3, 'citizenship', ' نشاطي\nسطر ثان ');
      expect(cubit.state.textOf(week, 'citizenship'), 'نشاطي\nسطر ثان');
      expect(cubit.state.isEdited(week, 'citizenship'), isTrue);

      cubit.setCell(3, 'occasion', '');
      expect(cubit.state.textOf(week, 'occasion'), '');

      cubit.setCell(3, 'citizenship', 'إذاعة مدرسية');
      expect(cubit.state.isEdited(week, 'citizenship'), isFalse);
      cubit.resetCell(3, 'occasion');
      expect(cubit.state.cells, isEmpty);
      await cubit.close();
    });

    test('save needs a stage and a domain', () async {
      final cubit = await loadLegacy();
      await cubit.save();
      expect(cubit.state.feedback?.message, 'activities_plan_stage_required');

      cubit.setStage('primary');
      await cubit.save();
      expect(cubit.state.feedback?.message, 'activities_plan_domains_required');
      verifyNever(() => documents.updateDocument(any(), any(), status: any(named: 'status')));
      await cubit.close();
    });

    test('save keeps the old layout: stage, domains and only the changed cells of the chosen columns', () async {
      final cubit = await loadLegacy();
      cubit.setStage('primary');
      cubit.toggleDomain('citizenship');
      cubit.toggleDomain('sports_health');
      await pumpEventQueue();
      cubit.setCell(3, 'sports_health', 'سباق');
      cubit.setCell(3, 'occasion', '');
      cubit.toggleDomain('sports_health');
      cubit.setRegion('western');
      cubit.activityLeaderController.text = ' نورة ';
      await cubit.saveAndAttach();

      final input = capturedUpdateInput();
      expect(input.containsKey('layout'), isFalse);
      expect(input.containsKey('band'), isFalse);
      expect(input['stage'], 'primary');
      expect(input['domains'], ['citizenship']);
      expect(input['region'], 'western');
      expect(input['activity_leader'], 'نورة');
      expect(input['cells'], {
        '3': {'occasion': ''},
      });
      expect(cubit.state.followUp, DocumentFollowUp.attachToPortfolio);
      expect(cubit.state.documentId, 30);
      await cubit.close();
    });

    test('reopening restores the choices, loads their grid and lays the changes over it', () async {
      final cubit = await loadLegacy(const {
        'stage': 'primary',
        'domains': ['citizenship'],
        'term': 2,
        'cells': {
          '3': {'citizenship': 'نشاطي'},
        },
        'notes': 'ملاحظة',
        'academic_year': '1448 هـ',
      });

      verify(() => activities.getGrid(stage: 'primary', term: 2, domains: ['citizenship'], region: null)).called(1);
      final week = cubit.state.grid!.weeks.single;
      expect(cubit.state.textOf(week, 'citizenship'), 'نشاطي');
      expect(cubit.state.textOf(week, 'occasion'), 'اليوم الوطني');
      expect(cubit.notesController.text, 'ملاحظة');
      expect(cubit.academicYearController.text, '1448 هـ');
      await cubit.close();
    });
  });

  test('load fails when the catalogue fails', () async {
    when(() => activities.getCatalogue()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, ActivitiesPlanStatus.failure);
    await cubit.close();
  });

  test('the calendar shown follows the pick, else the grid, else the defaults', () async {
    when(() => documents.getDefaults())
        .thenAnswer((_) async => const Right(DocumentDefaultsModel(regionCalendar: DocumentRegionCalendar.western)));
    final cubit = build();
    await cubit.load();
    expect(cubit.state.effectiveRegion, 'western');

    cubit.setBand('primary_early');
    await pumpEventQueue();
    expect(cubit.state.effectiveRegion, 'general');

    cubit.setRegion('western');
    expect(cubit.state.effectiveRegion, 'western');
    await cubit.close();
  });
}

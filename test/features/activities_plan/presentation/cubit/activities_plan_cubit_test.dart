import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/activities_plan/data/models/activities_catalogue_model.dart';
import 'package:moean/features/activities_plan/data/models/activities_grid_model.dart';
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

  void stubGrid([Future<Either<Failure, ActivitiesGridModel>> Function()? answer]) => when(
        () => activities.getGrid(
          stage: any(named: 'stage'),
          term: any(named: 'term'),
          domains: any(named: 'domains'),
          region: any(named: 'region'),
        ),
      ).thenAnswer((_) => answer?.call() ?? Future.value(const Right(_grid)));

  Map<String, dynamic> capturedCreateInput() => verify(
        () => documents.createDocument(
          type: DocumentTypes.activitiesPlan,
          input: captureAny(named: 'input'),
          status: any(named: 'status'),
        ),
      ).captured.single as Map<String, dynamic>;

  setUp(() {
    activities = MockActivitiesRepository();
    documents = MockDocumentsRepository();
    when(() => activities.getCatalogue()).thenAnswer((_) async => const Right(_catalogue));
    when(() => documents.getDefaults()).thenAnswer((_) async => const Right(DocumentDefaultsModel()));
    when(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(30)));
    stubGrid();
  });

  test('load fetches the catalogue; no grid until a stage and a domain are chosen', () async {
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, ActivitiesPlanStatus.success);
    expect(cubit.state.catalogue.stages.single.key, 'primary');
    expect(cubit.state.gridStatus, ActivitiesGridStatus.idle);
    verifyNever(() => activities.getGrid(
          stage: any(named: 'stage'),
          term: any(named: 'term'),
          domains: any(named: 'domains'),
          region: any(named: 'region'),
        ));
    await cubit.close();
  });

  test('load fails when the catalogue fails', () async {
    when(() => activities.getCatalogue()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, ActivitiesPlanStatus.failure);
    await cubit.close();
  });

  test('choosing a stage and domains loads the grid, columns in the picked order', () async {
    final cubit = build();
    await cubit.load();
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
    final cubit = build();
    await cubit.load();
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
    final cubit = build();
    await cubit.load();
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
    final cubit = build();
    await cubit.load();
    await cubit.save();
    expect(cubit.state.feedback?.message, 'activities_plan_stage_required');

    cubit.setStage('primary');
    await cubit.save();
    expect(cubit.state.feedback?.message, 'activities_plan_domains_required');
    verifyNever(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')));
    await cubit.close();
  });

  test('save sends only the changed cells of the chosen columns', () async {
    final cubit = build();
    await cubit.load();
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

    final input = capturedCreateInput();
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
    when(() => documents.getDocument(30)).thenAnswer((_) async => Right(_saved(30, input: const {
          'stage': 'primary',
          'domains': ['citizenship'],
          'term': 2,
          'cells': {
            '3': {'citizenship': 'نشاطي'},
          },
          'notes': 'ملاحظة',
          'academic_year': '1448 هـ',
        })));
    final cubit = build(documentId: 30);
    await cubit.load();

    verify(() => activities.getGrid(stage: 'primary', term: 2, domains: ['citizenship'], region: null)).called(1);
    final week = cubit.state.grid!.weeks.single;
    expect(cubit.state.textOf(week, 'citizenship'), 'نشاطي');
    expect(cubit.state.textOf(week, 'occasion'), 'اليوم الوطني');
    expect(cubit.notesController.text, 'ملاحظة');
    expect(cubit.academicYearController.text, '1448 هـ');
    await cubit.close();
  });

  test('the calendar shown follows the pick, else the grid, else the defaults', () async {
    when(() => documents.getDefaults())
        .thenAnswer((_) async => const Right(DocumentDefaultsModel(regionCalendar: DocumentRegionCalendar.western)));
    final cubit = build();
    await cubit.load();
    expect(cubit.state.effectiveRegion, 'western');

    cubit.setStage('primary');
    cubit.toggleDomain('citizenship');
    await pumpEventQueue();
    expect(cubit.state.effectiveRegion, 'general');

    cubit.setRegion('western');
    expect(cubit.state.effectiveRegion, 'western');
    await cubit.close();
  });
}

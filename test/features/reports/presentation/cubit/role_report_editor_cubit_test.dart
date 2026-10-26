import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/ai_jobs_repository.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_catalogue_model.dart';
import 'package:moean/features/reports/data/models/role_report_editor_args.dart';
import 'package:moean/features/reports/data/repositories/reports_repository.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/data/repositories/role_suites_repository.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

class MockRoleSuitesRepository extends Mock implements RoleSuitesRepository {}

class MockAiJobsRepository extends Mock implements AiJobsRepository {}

const _catalogue = ReportCatalogueModel(
  templates: [],
  blockKinds: [],
  limits: ReportLimitsModel(blocks: 10, tableRows: 40),
);

List<List<String>> _eighteenWeekRows({String activityPrefix = ''}) => [
      for (var w = 1; w <= 18; w++)
        ['$w', '1448/03/${w.toString().padLeft(2, '0')}', activityPrefix.isEmpty ? '' : '$activityPrefix $w'],
    ];

void main() {
  late MockReportsRepository reports;
  late MockDocumentsRepository documents;
  late MockDeviceFilePicker picker;
  late MockRoleSuitesRepository roleSuites;
  late MockAiJobsRepository aiJobs;

  setUpAll(() {
    registerFallbackValue(DeviceFileSource.gallery);
    registerFallbackValue(DevicePickedFile(bytes: Uint8List(0), name: '', mime: null));
  });

  setUp(() {
    reports = MockReportsRepository();
    documents = MockDocumentsRepository();
    picker = MockDeviceFilePicker();
    roleSuites = MockRoleSuitesRepository();
    aiJobs = MockAiJobsRepository();

    when(() => reports.getCatalogue()).thenAnswer((_) async => const Right(_catalogue));
    when(() => documents.getDefaults()).thenAnswer(
      (_) async => const Right(DocumentDefaultsModel(genderForm: DocumentGenderForm.female)),
    );
  });

  ReportEditorCubit buildCubit(RoleDocumentTemplateModel template) => ReportEditorCubit(
        reports: reports,
        documents: documents,
        picker: picker,
        roleSuites: roleSuites,
        aiJobs: aiJobs,
        roleArgs: RoleReportEditorArgs.fromTemplate(template),
        aiPollInterval: Duration.zero,
      );

  test('opens a role report and saves without editing, forwarding element to POST /documents', () async {
    const template = RoleDocumentTemplateModel(
      role: 'activity_leader',
      doc: 'program_report',
      type: 'report',
      label: 'تقرير برنامج نشاط',
      ai: true,
      element: 'school_community',
      input: {
        'title': 'تقرير برنامج نشاط',
        'blocks': [
          {'kind': 'heading', 'text': 'أهداف البرنامج'},
        ],
      },
    );
    when(
      () => documents.createDocument(
        type: DocumentTypes.report,
        input: any(named: 'input'),
        status: any(named: 'status'),
        element: 'school_community',
        keepFieldErrors: true,
      ),
    ).thenAnswer(
      (_) async => const Right(
        DocumentModel(
          id: 77,
          type: DocumentTypes.report,
          title: 'تقرير برنامج نشاط',
          status: DocumentStatus.draft,
        ),
      ),
    );

    final cubit = buildCubit(template);
    await cubit.load();
    expect(cubit.state.status, ReportEditorStatus.success);
    expect(cubit.activePortfolioItemKey, 'school_community');

    await cubit.save();
    expect(cubit.state.documentId, 77);
    verify(
      () => documents.createDocument(
        type: DocumentTypes.report,
        input: any(named: 'input'),
        status: DocumentStatus.draft,
        element: 'school_community',
        keepFieldErrors: true,
      ),
    ).called(1);
    await cubit.close();
  });

  test('«✨ اكتب لي» polls AI job, preserves 18 weekly plan dates & typed meta, marks dirty, and supports undo', () async {
    final weeklyTemplate = RoleDocumentTemplateModel(
      role: 'activity_leader',
      doc: 'weekly_plan',
      type: 'report',
      label: 'الخطة الأسبوعية',
      ai: true,
      term: 'first',
      region: 'riyadh',
      input: {
        'title': 'الخطة الأسبوعية للنشاط',
        'meta': [
          {'label': 'اسم الرائد', 'value': 'أ. نورة'},
        ],
        'blocks': [
          {
            'kind': 'table',
            'columns': ['الأسبوع', 'التاريخ', 'البرنامج'],
            'rows': _eighteenWeekRows(),
          },
        ],
      },
    );

    Map<String, dynamic>? sentPayload;
    when(() => aiJobs.start(AiJobKinds.roleDocument, any())).thenAnswer((inv) async {
      sentPayload = inv.positionalArguments[1] as Map<String, dynamic>;
      return const Right(
        AiJobModel(id: 101, kind: AiJobKinds.roleDocument, status: AiJobStatus.pending),
      );
    });
    when(() => aiJobs.getJob(101)).thenAnswer(
      (_) async => Right(
        AiJobModel(
          id: 101,
          kind: AiJobKinds.roleDocument,
          status: AiJobStatus.done,
          rawResult: {
            'title': 'الخطة الأسبوعية للنشاط الطلابي',
            'meta': [
              {'label': 'اسم الرائد', 'value': ''},
            ],
            'blocks': [
              {
                'kind': 'table',
                'columns': ['الأسبوع', 'التاريخ', 'البرنامج'],
                'rows': _eighteenWeekRows(activityPrefix: 'برنامج الأسبوع'),
              },
            ],
          },
        ),
      ),
    );

    final cubit = buildCubit(weeklyTemplate);
    await cubit.load();

    cubit.briefController.text = 'خطة نشاط ثقافي وعلمي متوازن';
    cubit.stageController.text = 'المتوسطة';
    await cubit.writeWithAi();

    expect(sentPayload, {
      'role': 'activity_leader',
      'doc': 'weekly_plan',
      'brief': 'خطة نشاط ثقافي وعلمي متوازن',
      'stage': 'المتوسطة',
      'gender': 'female',
      'term': 'first',
      'region': 'riyadh',
    });
    expect(cubit.state.aiStatus, RoleAiStatus.done);
    expect(cubit.state.isDirty, isTrue);
    expect(cubit.state.canUndoAi, isTrue);
    expect(cubit.state.input.meta.single.value, 'أ. نورة');

    final tableAfterAi = cubit.state.input.blocks.single as TableBlock;
    expect(tableAfterAi.rows, hasLength(18));
    expect(tableAfterAi.rows.first[0], '1');
    expect(tableAfterAi.rows.first[1], '1448/03/01');
    expect(tableAfterAi.rows.last[0], '18');
    expect(tableAfterAi.rows.last[1], '1448/03/18');
    expect(tableAfterAi.rows.first[2], 'برنامج الأسبوع 1');

    // Undo restores the pre-merge state.
    cubit.undoAiMerge();
    expect(cubit.titleController.text, 'الخطة الأسبوعية للنشاط');
    expect(cubit.state.isDirty, isFalse);
    expect(cubit.state.canUndoAi, isFalse);
    expect((cubit.state.input.blocks.single as TableBlock).rows.first[2], '');
    await cubit.close();
  });

  test('handles failed AI job + retry, 429 RateLimitFailure, and 402 PaymentRequiredFailure', () async {
    const template = RoleDocumentTemplateModel(
      role: 'health_guide',
      doc: 'awareness_report',
      type: 'report',
      label: 'تقرير توعوي',
      ai: true,
      input: {'title': 'تقرير توعوي', 'blocks': []},
    );

    when(() => aiJobs.start(AiJobKinds.roleDocument, any())).thenAnswer(
      (_) async => const Right(
        AiJobModel(
          id: 202,
          kind: AiJobKinds.roleDocument,
          status: AiJobStatus.failed,
          error: 'فشل التوليد مؤقتًا',
        ),
      ),
    );

    final cubit = buildCubit(template);
    await cubit.load();
    cubit.briefController.text = 'توعية عن الإفطار الصحي';
    await cubit.writeWithAi();

    expect(cubit.state.aiStatus, RoleAiStatus.failed);
    expect(cubit.state.aiErrorMessage, 'فشل التوليد مؤقتًا');

    // Retry sends the same POST; this time 429 rate limit is returned.
    when(() => aiJobs.start(AiJobKinds.roleDocument, any())).thenAnswer(
      (_) async => const Left(RateLimitFailure('بلغت الحد اليومي للذكاء الاصطناعي')),
    );
    await cubit.retryWriteWithAi();
    expect(cubit.state.aiStatus, RoleAiStatus.rateLimited);
    expect(cubit.state.aiErrorMessage, 'بلغت الحد اليومي للذكاء الاصطناعي');

    // 402 sets paymentRequired.
    when(() => aiJobs.start(AiJobKinds.roleDocument, any())).thenAnswer(
      (_) async => const Left(PaymentRequiredFailure('ترقية الحساب', code: 'subscription_required')),
    );
    await cubit.retryWriteWithAi();
    expect(cubit.state.paymentRequired?.code, 'subscription_required');
    await cubit.close();
  });

  test('sensitive form disables AI, hides images block kind, empties meta values, and saves empty images', () async {
    const sensitiveTemplate = RoleDocumentTemplateModel(
      role: 'student_counsellor',
      doc: 'case_referral',
      type: 'report',
      label: 'نموذج إحالة طالب',
      ai: true,
      sensitive: true,
      input: {
        'title': 'نموذج إحالة طالب',
        'meta': [
          {'label': 'الصف', 'value': ''},
        ],
        'blocks': [
          {
            'kind': 'table',
            'columns': ['الملاحظة', 'الإجراء'],
            'rows': [
              ['', ''],
            ],
          },
        ],
      },
    );

    final cubit = buildCubit(sensitiveTemplate);
    await cubit.load();

    expect(cubit.state.isSensitive, isTrue);
    expect(cubit.state.canUseAi, isFalse);
    expect(cubit.state.blockKinds.contains(ReportBlockKinds.images), isFalse);

    cubit.addMeta('التاريخ', 'قيمة سرية');
    expect(cubit.state.input.meta.last.label, 'التاريخ');
    expect(cubit.state.input.meta.last.value, '');

    cubit.addBlock(ReportBlockKinds.images);
    expect(cubit.state.input.blocks.whereType<ImagesBlock>(), isEmpty);

    final file = DevicePickedFile(bytes: Uint8List(4), name: 'a.jpg', mime: 'image/jpeg');
    when(() => picker.pick(any())).thenAnswer((_) async => file);
    await cubit.addImage(DeviceFileSource.gallery);
    verifyNever(() => documents.uploadImage(any()));
    await cubit.close();
  });

  test('fillTableNames populates the configured names_column from «فصولي»', () async {
    const memberTemplate = RoleDocumentTemplateModel(
      role: 'activity_leader',
      doc: 'club_members',
      type: 'report',
      label: 'كشف أعضاء النادي',
      namesColumn: 1,
      input: {
        'title': 'كشف أعضاء النادي',
        'blocks': [
          {
            'kind': 'table',
            'columns': ['م', 'اسم الطالب', 'التوقيع'],
            'rows': [
              ['1', '', ''],
            ],
          },
        ],
      },
    );

    final cubit = buildCubit(memberTemplate);
    await cubit.load();
    final table = cubit.state.input.blocks.single as TableBlock;
    expect(cubit.state.namesColumnFor(table), 1);

    cubit.fillTableNames(table.id, ['عبدالله', 'سلطان']);
    final updated = cubit.state.input.blocks.single as TableBlock;
    expect(updated.rows, [
      ['1', 'عبدالله', ''],
      ['', 'سلطان', ''],
    ]);
    await cubit.close();
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/models/checklist_models.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/documents/data/models/plan_catalogue_model.dart';
import 'package:moean/features/documents/data/models/plan_form_input.dart';
import 'package:moean/features/documents/data/models/student_picker_result.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/repositories/plan_catalogue_repository.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_tool_config.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';

class MockPlanCatalogueRepository extends Mock implements PlanCatalogueRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

const _remedial = PlanToolConfig(
  documentType: DocumentTypes.remedialPlan,
  aiKind: AiJobKinds.remedialSuggestions,
  catalogueUrl: remedialToolApi,
  hasPlanType: true,
  hasImprovement: true,
);

const _enrichment = PlanToolConfig(
  documentType: DocumentTypes.enrichmentPlan,
  aiKind: AiJobKinds.enrichmentSuggestions,
  catalogueUrl: enrichmentToolApi,
  hasTargetGroups: true,
);

const _catalogue = PlanCatalogueModel(
  sections: [
    ChecklistCatalogueSection(key: 'weaknesses', label: 'نقاط الضعف', options: ['ضعف أ', 'ضعف ب']),
    ChecklistCatalogueSection(key: 'methods', label: 'أساليب العلاج', options: ['أسلوب أ']),
  ],
  improvementLabel: 'مستوى التحسن',
  improvementOptions: ['جيد', 'محدود'],
  targetGroups: ['المتفوقون', 'الموهوبون'],
);

PickedLessonModel _lesson(int id) =>
    PickedLessonModel(lessonId: id, lessonTitle: 'درس $id', subjectName: 'رياضيات', gradeName: 'الخامس');

DocumentModel _saved(int id, {Map<String, dynamic> input = const {}, Map<String, String> meta = const {}}) =>
    DocumentModel(
      id: id,
      type: DocumentTypes.remedialPlan,
      title: 'الخطة العلاجية',
      status: DocumentStatus.finalized,
      input: input,
      meta: meta,
    );

void main() {
  late MockPlanCatalogueRepository catalogues;
  late MockDocumentsRepository documents;

  PlanFormCubit build({PlanToolConfig config = _remedial, int? documentId}) => PlanFormCubit(
        config: config,
        documentId: documentId,
        catalogueRepository: catalogues,
        documentsRepository: documents,
        filePicker: MockDeviceFilePicker(),
      );

  Map<String, dynamic> capturedCreateInput() => verify(
        () => documents.createDocument(
          type: any(named: 'type'),
          input: captureAny(named: 'input'),
          status: any(named: 'status'),
        ),
      ).captured.single as Map<String, dynamic>;

  setUp(() {
    catalogues = MockPlanCatalogueRepository();
    documents = MockDocumentsRepository();
    when(() => catalogues.getCatalogue()).thenAnswer((_) async => const Right(_catalogue));
    when(() => documents.getDefaults()).thenAnswer((_) async => const Right(DocumentDefaultsModel()));
    when(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(21)));
  });

  test('load builds the sections from the catalogue, unticked', () async {
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, PlanFormStatus.success);
    expect(cubit.state.planType, PlanFormInput.linked);
    expect(cubit.state.sections.map((s) => s.key), ['weaknesses', 'methods']);
    expect(cubit.state.sections.expand((s) => s.checkedTexts), isEmpty);
    await cubit.close();
  });

  test('load fails when the catalogue fails', () async {
    when(() => catalogues.getCatalogue()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, PlanFormStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
    await cubit.close();
  });

  test('the enrichment plan has no plan type', () async {
    final cubit = build(config: _enrichment);
    await cubit.load();

    expect(cubit.state.planType, isNull);
    expect(cubit.state.usesLessons, isTrue);
    expect(cubit.state.targetGroups.lines.map((l) => l.text), ['المتفوقون', 'الموهوبون']);
    await cubit.close();
  });

  test('lessons: up to five, each once; the first fills subject and grade', () async {
    final cubit = build();
    await cubit.load();
    for (var id = 1; id <= 6; id++) {
      cubit.addLesson(_lesson(id));
    }
    cubit.addLesson(_lesson(1));

    expect(cubit.state.aiLessonIds, [1, 2, 3, 4, 5]);
    expect(cubit.state.feedback?.message, 'plan_lessons_limit');
    expect(cubit.subjectController.text, 'رياضيات');
    expect(cubit.gradeController.text, 'الخامس');
    await cubit.close();
  });

  test('a general plan hides the lessons from the AI and the input', () async {
    final cubit = build();
    await cubit.load();
    cubit.addLesson(_lesson(1));
    cubit.setPlanType(PlanFormInput.general);

    expect(cubit.state.aiLessonIds, isEmpty);
    await cubit.save();
    final input = capturedCreateInput();
    expect(input['plan_type'], 'general');
    expect(input.containsKey('lesson_ids'), isFalse);
    await cubit.close();
  });

  test('a linked remedial plan needs a lesson', () async {
    final cubit = build();
    await cubit.load();
    await cubit.save();

    expect(cubit.state.feedback?.message, 'plan_lessons_required');
    verifyNever(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')));
    await cubit.close();
  });

  test('an enrichment plan saves without lessons', () async {
    final cubit = build(config: _enrichment);
    await cubit.load();
    cubit.toggleLine(PlanFormState.targetGroupsKey, 0);
    cubit.addCustomLine(PlanFormState.targetGroupsKey, 'سريعو الإنجاز');
    await cubit.save();

    final input = capturedCreateInput();
    expect(input.containsKey('plan_type'), isFalse);
    expect(input['target_groups'], ['المتفوقون', 'سريعو الإنجاز']);
    expect(input.containsKey('improvement'), isFalse);
    await cubit.close();
  });

  test('suggestions join unticked and only ticked lines are saved, in order', () async {
    final cubit = build();
    await cubit.load();
    cubit.addLesson(_lesson(1));
    cubit.toggleLine('weaknesses', 1);
    cubit.addSuggestions(const {
      'weaknesses': ['ضعف ب', 'ضعف مقترح'],
      'methods': ['أسلوب مقترح'],
      'unknown': ['يتجاهل'],
    });

    expect(cubit.state.feedback?.message, 'ai_suggestions_added');
    final weaknesses = cubit.state.sectionOf('weaknesses')!;
    expect(weaknesses.lines.map((l) => l.text), ['ضعف أ', 'ضعف ب', 'ضعف مقترح']);
    expect(weaknesses.lines.last.origin, ChecklistOrigin.suggested);
    expect(weaknesses.checkedTexts, ['ضعف ب']);

    cubit.toggleLine('weaknesses', 2);
    cubit.addCustomLine('methods', 'أسلوبي');
    cubit.setImprovement('جيد');
    await cubit.save();

    final input = capturedCreateInput();
    expect(input['weaknesses'], ['ضعف ب', 'ضعف مقترح']);
    expect(input['methods'], ['أسلوبي']);
    expect(input['improvement'], 'جيد');
    expect(input['lesson_ids'], [1]);
    expect(cubit.state.documentId, 21);
    await cubit.close();
  });

  test('no new suggestions says so', () async {
    final cubit = build();
    await cubit.load();
    cubit.addSuggestions(const {
      'weaknesses': ['ضعف أ'],
    });

    expect(cubit.state.feedback?.message, 'ai_suggestions_empty');
    await cubit.close();
  });

  test('ticking stops at 20 lines per section', () async {
    final cubit = build();
    await cubit.load();
    for (var i = 0; i < 21; i++) {
      cubit.addCustomLine('methods', 'سطر $i');
    }

    expect(cubit.state.sectionOf('methods')!.checkedTexts.length, 20);
    expect(cubit.state.feedback?.message, 'plan_section_limit');
    await cubit.close();
  });

  test('tapping the chosen level again clears it', () async {
    final cubit = build();
    await cubit.load();
    cubit.setImprovement('جيد');
    cubit.setImprovement('جيد');

    expect(cubit.state.improvement, '');
    await cubit.close();
  });

  test('picked students fill the empty class details', () async {
    final cubit = build();
    await cubit.load();
    cubit.gradeController.text = 'السادس';
    cubit.setStudents(const StudentPickerResult(
      classId: 3,
      className: 'خامس 1',
      grade: 'الخامس',
      students: ['سارة', 'أحمد'],
    ));

    expect(cubit.state.students, ['سارة', 'أحمد']);
    expect(cubit.state.classId, 3);
    expect(cubit.classController.text, 'خامس 1');
    expect(cubit.gradeController.text, 'السادس');

    cubit.setStudents(const StudentPickerResult(students: ['خالد']));
    expect(cubit.state.classId, isNull);
    cubit.clearStudents();
    expect(cubit.state.students, isEmpty);
    await cubit.close();
  });

  test('reopening restores the ticked, custom and AI lines, and the lesson titles', () async {
    when(() => documents.getDocument(21)).thenAnswer((_) async => Right(_saved(
          21,
          input: const {
            'plan_type': 'linked',
            'lesson_ids': [12, 13],
            'subject': 'رياضيات',
            'class_id': 3,
            'students': ['سارة'],
            'weaknesses': ['ضعف ب', 'سطر مقترح سابق'],
            'improvement': 'محدود',
            'academic_year': '1448 هـ',
          },
          meta: const {'الدروس': 'الكسور، الأعداد العشرية'},
        )));
    final cubit = build(documentId: 21);
    await cubit.load();

    final weaknesses = cubit.state.sectionOf('weaknesses')!;
    expect(weaknesses.checkedTexts, ['ضعف ب', 'سطر مقترح سابق']);
    expect(weaknesses.lines.last.isCustom, isTrue);
    expect(cubit.state.lessons.map((l) => l.lessonTitle), ['الكسور', 'الأعداد العشرية']);
    expect(cubit.state.improvement, 'محدود');
    expect(cubit.state.documentStatus, DocumentStatus.finalized);
    expect(cubit.subjectController.text, 'رياضيات');

    when(() => documents.updateDocument(21, any(), status: any(named: 'status'))).thenAnswer((_) async => Right(_saved(21)));
    await cubit.saveAndExport();
    final input = verify(() => documents.updateDocument(21, captureAny(), status: any(named: 'status'))).captured.single
        as Map<String, dynamic>;
    expect(input['academic_year'], '1448 هـ');
    expect(input['weaknesses'], ['ضعف ب', 'سطر مقترح سابق']);
    expect(cubit.state.followUp, DocumentFollowUp.export);
    await cubit.close();
  });

  group('savedLessons', () {
    test('one lesson takes the whole meta value', () {
      final lessons = PlanFormCubit.savedLessons(const [5], const {'الدرس': 'الجمع، والطرح'});
      expect(lessons.single.lessonTitle, 'الجمع، والطرح');
    });

    test('titles that do not match the ids fall back to empty', () {
      final lessons = PlanFormCubit.savedLessons(const [5, 6, 7], const {'الدروس': 'أ، ب'});
      expect(lessons.map((l) => l.lessonTitle), ['', '', '']);
      expect(lessons.map((l) => l.lessonId), [5, 6, 7]);
    });
  });
}

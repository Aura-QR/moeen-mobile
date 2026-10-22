import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/models/picked_lesson_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_models.dart';
import 'package:moean/features/strategy_documentation/data/repositories/strategy_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/strategy_documentation/presentation/cubit/strategy_documentation_cubit.dart';

class MockStrategyRepository extends Mock implements StrategyRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

const _catalogue = StrategyCatalogueModel(
  categories: [StrategyCategoryModel(key: 'cooperative', label: 'التعلم التعاوني')],
  items: [StrategySummaryModel(key: 'jigsaw', name: 'جيكسو', category: 'cooperative')],
);

const _jigsaw = StrategyDetailsModel(
  key: 'jigsaw',
  name: 'جيكسو',
  definition: 'تعريف جيكسو',
  lists: {
    StrategyListSection.steps: ['خطوة 1', 'خطوة 2', 'خطوة 3'],
    StrategyListSection.teacherRole: ['دور المعلم'],
    StrategyListSection.studentRole: ['دور الطالب'],
    StrategyListSection.outcomes: ['ناتج'],
  },
);

const _defaults = DocumentDefaultsModel(texts: {DocumentHeaderField.schoolName: 'ابتدائية الأمل'});

DocumentModel _saved(int id, {Map<String, dynamic> input = const {}, List<DocumentImageModel> images = const []}) =>
    DocumentModel(
      id: id,
      type: DocumentTypes.strategyDocumentation,
      title: 'توثيق جيكسو',
      status: DocumentStatus.draft,
      input: input,
      images: images,
    );

void main() {
  late MockStrategyRepository strategies;
  late MockDocumentsRepository documents;
  late MockDeviceFilePicker picker;

  StrategyDocumentationCubit build({int? documentId}) => StrategyDocumentationCubit(
        documentId: documentId,
        strategyRepository: strategies,
        documentsRepository: documents,
        filePicker: picker,
      );

  setUpAll(() => registerFallbackValue(DevicePickedFile(bytes: Uint8List(0), name: 'x', mime: null)));

  setUp(() {
    strategies = MockStrategyRepository();
    documents = MockDocumentsRepository();
    picker = MockDeviceFilePicker();
    when(() => strategies.getCatalogue()).thenAnswer((_) async => const Right(_catalogue));
    when(() => strategies.getStrategy('jigsaw')).thenAnswer((_) async => const Right(_jigsaw));
    when(() => documents.getDefaults()).thenAnswer((_) async => const Right(_defaults));
  });

  Map<String, dynamic> capturedCreateInput() => verify(
        () => documents.createDocument(
          type: DocumentTypes.strategyDocumentation,
          input: captureAny(named: 'input'),
          status: any(named: 'status'),
        ),
      ).captured.single as Map<String, dynamic>;

  test('load fetches the catalogue and defaults', () async {
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, StrategyDocumentationStatus.success);
    expect(cubit.state.catalogue.items.single.key, 'jigsaw');
    expect(cubit.state.defaults.text(DocumentHeaderField.schoolName), 'ابتدائية الأمل');
    await cubit.close();
  });

  test('load fails when the catalogue fails', () async {
    when(() => strategies.getCatalogue()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, StrategyDocumentationStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
    await cubit.close();
  });

  test('selecting a strategy fills the content from the catalogue', () async {
    final cubit = build();
    await cubit.load();
    await cubit.selectStrategy('jigsaw');

    expect(cubit.state.strategyName, 'جيكسو');
    expect(cubit.definitionController.text, 'تعريف جيكسو');
    expect(cubit.state.listOf(StrategyListSection.steps), ['خطوة 1', 'خطوة 2', 'خطوة 3']);
    await cubit.close();
  });

  test('list edits: add, edit, clear-to-remove, reorder and reset', () async {
    final cubit = build();
    await cubit.load();
    await cubit.selectStrategy('jigsaw');
    const steps = StrategyListSection.steps;

    cubit.addListItem(steps, '  خطوة 4 ');
    cubit.addListItem(steps, '   ');
    cubit.editListItem(steps, 0, 'خطوة أولى');
    cubit.editListItem(steps, 1, '');
    cubit.reorderListItem(steps, 2, 0);
    expect(cubit.state.listOf(steps), ['خطوة 4', 'خطوة أولى', 'خطوة 3']);

    cubit.resetList(steps);
    expect(cubit.state.listOf(steps), _jigsaw.lists[steps]);
    await cubit.close();
  });

  test('a list stops growing at its limit', () async {
    final cubit = build();
    await cubit.load();
    await cubit.selectStrategy('jigsaw');
    for (var i = 0; i < 20; i++) {
      cubit.addListItem(StrategyListSection.outcomes, 'ناتج $i');
    }

    expect(cubit.state.listOf(StrategyListSection.outcomes).length, StrategyListSection.outcomes.maxItems);
    await cubit.close();
  });

  test('save without a strategy asks for one', () async {
    final cubit = build();
    await cubit.load();
    await cubit.save();

    expect(cubit.state.feedback?.message, 'strategy_required');
    verifyNever(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')));
    await cubit.close();
  });

  test('students must be between 1 and 200, Arabic digits allowed', () async {
    when(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(12)));
    final cubit = build();
    await cubit.load();
    await cubit.selectStrategy('jigsaw');

    cubit.studentsController.text = '٢٠١';
    await cubit.save();
    expect(cubit.state.feedback?.message, 'strategy_students_invalid');

    cubit.studentsController.text = '٢٨';
    await cubit.save();
    expect(capturedCreateInput()['students_count'], 28);
    await cubit.close();
  });

  test('first save creates, the next one patches the same document', () async {
    when(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(12)));
    when(() => documents.updateDocument(12, any(), status: any(named: 'status'))).thenAnswer((_) async => Right(_saved(12)));
    final cubit = build();
    await cubit.load();
    await cubit.selectStrategy('jigsaw');
    cubit.subjectController.text = ' العلوم ';
    cubit.setTheme(DocumentTheme.purple);
    await cubit.save();

    final input = capturedCreateInput();
    expect(input['strategy_key'], 'jigsaw');
    expect(input['subject'], 'العلوم');
    expect(input['theme'], 'purple');
    expect((input['content'] as Map)['definition'], 'تعريف جيكسو');
    expect(cubit.state.documentId, 12);
    expect(cubit.state.feedback?.message, 'document_saved');

    await cubit.save();
    verify(() => documents.updateDocument(12, any(), status: any(named: 'status'))).called(1);
    await cubit.close();
  });

  test('saveAndExport saves first, then asks to open the export sheet', () async {
    when(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(12)));
    final cubit = build();
    await cubit.load();
    await cubit.selectStrategy('jigsaw');
    await cubit.saveAndExport();

    expect(cubit.state.followUp, DocumentFollowUp.export);
    expect(cubit.state.documentId, 12);
    await cubit.close();
  });

  test('a picked lesson sends lesson_id until its title is edited', () async {
    when(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(12)));
    final cubit = build();
    await cubit.load();
    await cubit.selectStrategy('jigsaw');
    cubit.pickLesson(const PickedLessonModel(
      lessonId: 55,
      lessonTitle: 'دورة الماء',
      subjectName: 'العلوم',
      gradeName: 'الخامس الابتدائي',
    ));

    expect(cubit.subjectController.text, 'العلوم');
    expect(cubit.gradeController.text, 'الخامس الابتدائي');

    cubit.lessonController.text = 'دورة الماء في الطبيعة';
    await cubit.save();
    final input = capturedCreateInput();
    expect(input.containsKey('lesson_id'), isFalse);
    expect(input['lesson_title'], 'دورة الماء في الطبيعة');
    await cubit.close();
  });

  test('header overrides are sent only when enabled and different', () async {
    when(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(12)));
    final cubit = build();
    await cubit.load();
    await cubit.selectStrategy('jigsaw');
    cubit.setHeaderOverride(true);
    expect(cubit.header.controllers[DocumentHeaderField.schoolName]!.text, 'ابتدائية الأمل');

    cubit.header.controllers[DocumentHeaderField.principalName]!.text = 'أ. نورة';
    await cubit.save();

    expect(capturedCreateInput()['header'], {'principal_name': 'أ. نورة'});
    await cubit.close();
  });

  test('reopening fills the form from input and keeps edited content', () async {
    when(() => documents.getDocument(12)).thenAnswer((_) async => Right(_saved(
          12,
          input: {
            'strategy_key': 'jigsaw',
            'lesson_title': 'دورة الماء',
            'students_count': 28,
            'content': {
              'definition': 'تعريف معدل',
              'steps': ['خطوتي'],
            },
            'header': {'principal_name': 'أ. نورة'},
            'theme': 'blue',
            'images': ['documents/12/uploads/a.jpg'],
          },
          images: const [DocumentImageModel(storagePath: 'documents/12/uploads/a.jpg', url: 'https://r2/a.jpg')],
        )));
    final cubit = build(documentId: 12);
    await cubit.load();

    expect(cubit.lessonController.text, 'دورة الماء');
    expect(cubit.studentsController.text, '28');
    expect(cubit.definitionController.text, 'تعريف معدل');
    expect(cubit.state.listOf(StrategyListSection.steps), ['خطوتي']);
    expect(cubit.state.listOf(StrategyListSection.outcomes), ['ناتج']);
    expect(cubit.state.isOverridingHeader, isTrue);
    expect(cubit.header.controllers[DocumentHeaderField.schoolName]!.text, 'ابتدائية الأمل');
    expect(cubit.state.theme, DocumentTheme.blue);
    expect(cubit.state.images.single.url, 'https://r2/a.jpg');
    expect(cubit.state.strategy, isNotNull);
    await cubit.close();
  });

  test('photos upload up to six, then refuse more', () async {
    final photo = DevicePickedFile(bytes: Uint8List.fromList([1]), name: 'a.jpg', mime: 'image/jpeg');
    when(() => picker.pick(DeviceFileSource.camera)).thenAnswer((_) async => photo);
    var uploads = 0;
    when(() => documents.uploadImage(photo)).thenAnswer((_) async => Right('documents/12/uploads/${uploads++}.jpg'));
    final cubit = build();
    await cubit.load();
    for (var i = 0; i < 7; i++) {
      await cubit.addImage(DeviceFileSource.camera);
    }

    expect(cubit.state.images.length, 6);
    expect(cubit.state.images.first.bytes, photo.bytes);
    expect(cubit.state.feedback?.message, 'document_images_limit');

    cubit.removeImage(0);
    expect(cubit.state.images.first.storagePath, 'documents/12/uploads/1.jpg');
    await cubit.close();
  });

  test('the chosen status is sent with the save, and restored when reopening', () async {
    when(() => documents.createDocument(type: any(named: 'type'), input: any(named: 'input'), status: any(named: 'status')))
        .thenAnswer((_) async => Right(_saved(12)));
    final cubit = build();
    await cubit.load();
    await cubit.selectStrategy('jigsaw');
    expect(cubit.state.documentStatus, DocumentStatus.draft);

    cubit.setDocumentStatus(DocumentStatus.finalized);
    await cubit.save();
    verify(() => documents.createDocument(
          type: DocumentTypes.strategyDocumentation,
          input: any(named: 'input'),
          status: DocumentStatus.finalized,
        )).called(1);
    await cubit.close();

    when(() => documents.getDocument(13)).thenAnswer((_) async => Right(DocumentModel(
          id: 13,
          type: DocumentTypes.strategyDocumentation,
          title: 'توثيق جيكسو',
          status: DocumentStatus.finalized,
          input: const {'strategy_key': 'jigsaw'},
        )));
    final reopened = build(documentId: 13);
    await reopened.load();
    expect(reopened.state.documentStatus, DocumentStatus.finalized);
    await reopened.close();
  });
}

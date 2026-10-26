import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_catalogue_model.dart';
import 'package:moean/features/reports/data/repositories/reports_repository.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

const _catalogue = ReportCatalogueModel(templates: [], blockKinds: [], limits: ReportLimitsModel(blocks: 3));

Map<String, dynamic> _template() => {
      'template': 'blank',
      'title': 'تقرير',
      'blocks': [
        {'kind': 'heading', 'text': 'أ'},
        {'kind': 'paragraph', 'text': 'ب'},
      ],
    };

DocumentModel _saved({int id = 9}) =>
    DocumentModel(id: id, type: DocumentTypes.report, title: 'تقرير', status: DocumentStatus.draft, input: _template());

void main() {
  late MockReportsRepository reports;
  late MockDocumentsRepository documents;
  late MockDeviceFilePicker picker;

  ReportEditorCubit build({int? documentId}) =>
      ReportEditorCubit(reports: reports, documents: documents, picker: picker, documentId: documentId);

  setUpAll(() => registerFallbackValue(DeviceFileSource.gallery));

  setUp(() {
    reports = MockReportsRepository();
    documents = MockDocumentsRepository();
    picker = MockDeviceFilePicker();
    when(() => reports.getCatalogue()).thenAnswer((_) async => const Right(_catalogue));
    when(() => reports.getTemplate('blank')).thenAnswer((_) async => Right(_template()));
  });

  test('a new report starts from the template', () async {
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, ReportEditorStatus.success);
    expect(cubit.titleController.text, 'تقرير');
    expect(cubit.state.input.blocks.map((b) => b.kind), ['heading', 'paragraph']);
    verifyNever(() => documents.getDocument(any()));
    await cubit.close();
  });

  test('a saved report opens without the template', () async {
    when(() => documents.getDocument(9)).thenAnswer((_) async => Right(_saved()));
    final cubit = build(documentId: 9);
    await cubit.load();

    expect(cubit.state.input.blocks, hasLength(2));
    verifyNever(() => reports.getTemplate(any()));
    await cubit.close();
  });

  test('a load failure shows the error', () async {
    when(() => reports.getCatalogue()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final cubit = build();
    await cubit.load();

    expect(cubit.state.status, ReportEditorStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
    await cubit.close();
  });

  test('blocks are added up to the limit, duplicated, moved and removed', () async {
    final cubit = build();
    await cubit.load();
    final first = cubit.state.input.blocks.first.id;

    cubit.addBlock(ReportBlockKinds.table);
    expect(cubit.state.input.blocks, hasLength(3));
    expect(cubit.state.isDirty, isTrue);
    cubit.addBlock(ReportBlockKinds.list);
    expect(cubit.state.input.blocks, hasLength(3));
    expect(cubit.state.feedback?.message, 'report_limit_reached');

    cubit.removeBlock(cubit.state.input.blocks.last.id);
    cubit.duplicateBlock(first);
    expect(cubit.state.input.blocks[1], isA<HeadingBlock>());
    expect(cubit.state.input.blocks[1].id, isNot(first));

    cubit.moveBlock(0, 2);
    expect(cubit.state.input.blocks.last.id, first);
    await cubit.close();
  });

  test('a photo taken out of the report leaves its images blocks', () async {
    final file = DevicePickedFile(bytes: Uint8List(4), name: 'a.jpg', mime: 'image/jpeg');
    when(() => picker.pick(any())).thenAnswer((_) async => file);
    when(() => documents.uploadImage(file)).thenAnswer((_) async => const Right('documents/a.jpg'));
    final cubit = build();
    await cubit.load();
    cubit.removeBlock(cubit.state.input.blocks.last.id);

    await cubit.addImage(DeviceFileSource.gallery);
    cubit.addBlock(ReportBlockKinds.images);
    final block = cubit.state.input.blocks.last as ImagesBlock;
    cubit.updateBlock(block.copyWith(items: ['documents/a.jpg']));
    cubit.removeImage(0);

    expect(cubit.state.images, isEmpty);
    expect((cubit.state.input.blocks.last as ImagesBlock).items, isEmpty);
    await cubit.close();
  });

  test('saving needs a title', () async {
    final cubit = build();
    await cubit.load();
    cubit.titleController.text = ' ';

    await cubit.save();

    expect(cubit.state.titleError, 'report_title_required');
    verifyNever(() => documents.createDocument(
          type: any(named: 'type'),
          input: any(named: 'input'),
          status: any(named: 'status'),
        ));
    await cubit.close();
  });

  test('an http QR link is caught before sending', () async {
    final cubit = build();
    await cubit.load();
    cubit.addBlock(ReportBlockKinds.qr);
    final qr = cubit.state.input.blocks.last as QrBlock;
    cubit.updateBlock(qr.copyWith(url: 'http://example.com'));

    await cubit.save();

    expect(cubit.state.blockErrors[qr.id], 'report_qr_url_invalid');
    expect(cubit.state.scrollToBlockId, qr.id);
    await cubit.close();
  });

  test('saving a new report creates it, then opens the export', () async {
    when(() => documents.createDocument(
          type: DocumentTypes.report,
          input: any(named: 'input'),
          status: any(named: 'status'),
          keepFieldErrors: true,
        )).thenAnswer((_) async => Right(_saved(id: 12)));
    final cubit = build();
    await cubit.load();

    await cubit.saveAndExport();

    expect(cubit.state.documentId, 12);
    expect(cubit.state.followUp, DocumentFollowUp.export);
    expect(cubit.state.isDirty, isFalse);
    await cubit.close();
  });

  test('a server field error marks its block', () async {
    when(() => documents.createDocument(
          type: DocumentTypes.report,
          input: any(named: 'input'),
          status: any(named: 'status'),
          keepFieldErrors: true,
        )).thenAnswer((_) async => const Left(ValidationFailure('خطأ', {
              'input.blocks.1.text': ['النص طويل'],
            })));
    final cubit = build();
    await cubit.load();
    final second = cubit.state.input.blocks[1].id;

    await cubit.save();

    expect(cubit.state.blockErrors, {second: 'النص طويل'});
    expect(cubit.state.scrollToBlockId, second);
    expect(cubit.state.isSaving, isFalse);
    await cubit.close();
  });

  test('leaving saves only when something changed', () async {
    when(() => documents.getDocument(9)).thenAnswer((_) async => Right(_saved()));
    when(() => documents.updateDocument(9, any(), status: any(named: 'status'), keepFieldErrors: true))
        .thenAnswer((_) async => Right(_saved()));
    final cubit = build(documentId: 9);
    await cubit.load();

    await cubit.saveIfDirty();
    verifyNever(() => documents.updateDocument(any(), any(), status: any(named: 'status'), keepFieldErrors: true));

    cubit.addBlock(ReportBlockKinds.pageBreak);
    await cubit.saveIfDirty();
    verify(() => documents.updateDocument(9, any(), status: any(named: 'status'), keepFieldErrors: true)).called(1);
    expect(cubit.state.feedback, isNull);
    await cubit.close();
  });
}

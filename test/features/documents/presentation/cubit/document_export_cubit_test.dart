import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_export_models.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';
import 'package:moean/features/documents/presentation/cubit/document_export_cubit.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockDocumentFileService extends Mock implements DocumentFileService {}

const _id = 12;
final _pdf = Uint8List.fromList([1, 2, 3]);
final _png = Uint8List.fromList([4, 5]);

DocumentExportModel _export(String status, {String? error}) => DocumentExportModel(
      id: 31,
      format: 'docx',
      status: status,
      isCurrent: true,
      url: status == 'done' ? 'https://r2/a.docx' : null,
      fileName: 'توثيق جيكسو.docx',
      error: error,
    );

void main() {
  late MockDocumentsRepository repo;
  late MockDocumentFileService files;
  late DocumentExportCubit cubit;

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    repo = MockDocumentsRepository();
    files = MockDocumentFileService();
    cubit = DocumentExportCubit(
      documentId: _id,
      repository: repo,
      fileService: files,
      pollInterval: Duration.zero,
      maxPollAttempts: 3,
    );
    when(() => repo.getPrint(_id)).thenAnswer(
      (_) async => const Right(DocumentPrintModel(html: '<html></html>', fileName: 'توثيق جيكسو')),
    );
    when(() => files.htmlToPdf(any())).thenAnswer((_) async => Right(_pdf));
    when(() => files.share(any(), fileName: any(named: 'fileName'), mime: any(named: 'mime')))
        .thenAnswer((_) async => const Right(unit));
  });

  tearDown(() => cubit.close());

  test('PDF converts the print HTML and shares <file_name>.pdf', () async {
    await cubit.run(DocumentExportAction.pdf);

    verify(() => files.htmlToPdf('<html></html>')).called(1);
    verify(() => files.share(_pdf, fileName: 'توثيق جيكسو.pdf', mime: DocumentFileService.pdfMime)).called(1);
    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.errorMessage, isNull);
  });

  test('image rasterises the same PDF, made only once per sheet', () async {
    when(() => files.firstPageAsPng(_pdf)).thenAnswer((_) async => Right(_png));
    await cubit.run(DocumentExportAction.pdf);
    await cubit.run(DocumentExportAction.image);

    verify(() => repo.getPrint(_id)).called(1);
    verify(() => files.share(_png, fileName: 'توثيق جيكسو.png', mime: DocumentFileService.pngMime)).called(1);
  });

  test('Word polls until done, then downloads and shares the file', () async {
    final bytes = Uint8List.fromList([9]);
    when(() => repo.requestExport(_id, 'docx')).thenAnswer((_) async => Right(_export('pending')));
    var polls = 0;
    when(() => repo.getExport(_id, 31)).thenAnswer((_) async => Right(_export(++polls < 2 ? 'pending' : 'done')));
    when(() => repo.downloadFile('https://r2/a.docx')).thenAnswer((_) async => Right(bytes));
    await cubit.run(DocumentExportAction.word);

    expect(polls, 2);
    verify(() => files.share(bytes, fileName: 'توثيق جيكسو.docx', mime: DocumentFileService.docxMime)).called(1);
    expect(cubit.state.errorMessage, isNull);
  });

  test('Word that is already built skips polling', () async {
    when(() => repo.requestExport(_id, 'docx')).thenAnswer((_) async => Right(_export('done')));
    when(() => repo.downloadFile(any())).thenAnswer((_) async => Right(Uint8List(1)));
    await cubit.run(DocumentExportAction.word);

    verifyNever(() => repo.getExport(any(), any()));
  });

  test('a failed Word export shows the API error and can be retried', () async {
    when(() => repo.requestExport(_id, 'docx'))
        .thenAnswer((_) async => Right(_export('failed', error: 'تعذر تجهيز الملف، حاول مرة أخرى.')));
    await cubit.run(DocumentExportAction.word);

    expect(cubit.state.failedAction, DocumentExportAction.word);
    expect(cubit.state.errorMessage, 'تعذر تجهيز الملف، حاول مرة أخرى.');

    when(() => repo.requestExport(_id, 'docx')).thenAnswer((_) async => Right(_export('done')));
    when(() => repo.downloadFile(any())).thenAnswer((_) async => Right(Uint8List(1)));
    await cubit.retry();

    expect(cubit.state.errorMessage, isNull);
    verify(() => repo.requestExport(_id, 'docx')).called(2);
  });

  test('Word gives up after the polling limit', () async {
    when(() => repo.requestExport(_id, 'docx')).thenAnswer((_) async => Right(_export('pending')));
    when(() => repo.getExport(_id, 31)).thenAnswer((_) async => Right(_export('pending')));
    await cubit.run(DocumentExportAction.word);

    verify(() => repo.getExport(_id, 31)).called(3);
    expect(cubit.state.errorMessage, 'document_export_timeout');
  });

  test('a print request failure surfaces as an error', () async {
    when(() => repo.getPrint(_id)).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    await cubit.run(DocumentExportAction.print);

    verifyNever(() => files.printPdf(any(), name: any(named: 'name')));
    expect(cubit.state.errorMessage, 'network_error');
  });
}

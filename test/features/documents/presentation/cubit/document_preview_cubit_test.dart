import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_export_models.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';
import 'package:moean/features/documents/presentation/cubit/document_preview_cubit.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockDocumentFileService extends Mock implements DocumentFileService {}

final _pdf = Uint8List.fromList([1, 2, 3]);
final _png = Uint8List.fromList([4, 5]);

void main() {
  late MockDocumentsRepository repo;
  late MockDocumentFileService files;

  DocumentPreviewCubit build() => DocumentPreviewCubit(
    type: DocumentTypes.certificates,
    repository: repo,
    fileService: files,
    debounce: const Duration(milliseconds: 20),
  );

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    repo = MockDocumentsRepository();
    files = MockDocumentFileService();
    when(
      () => repo.previewDocument(any(), any()),
    ).thenAnswer((_) async => const Right(DocumentPrintModel(html: '<html></html>', fileName: 'شهادة')));
    when(() => files.htmlToPdf(any(), landscape: any(named: 'landscape'))).thenAnswer((_) async => Right(_pdf));
    when(() => files.firstPageAsPng(any())).thenAnswer((_) async => Right(_png));
  });

  test('a certificate preview is rendered landscape and shown as an image', () async {
    final cubit = build();
    await cubit.render({
      'names': ['ريم'],
    });

    expect(cubit.state.status, DocumentPreviewStatus.success);
    expect(cubit.state.image, _png);
    verify(
      () => repo.previewDocument(DocumentTypes.certificates, {
        'names': ['ريم'],
      }),
    ).called(1);
    verify(() => files.htmlToPdf('<html></html>', landscape: true)).called(1);
    await cubit.close();
  });

  test('changes in a row render once, after the debounce', () async {
    final cubit = build();
    cubit.schedule({'title': 'أ'});
    cubit.schedule({'title': 'أب'});
    await Future<void>.delayed(const Duration(milliseconds: 60));

    verify(() => repo.previewDocument(any(), {'title': 'أب'})).called(1);
    verifyNever(() => repo.previewDocument(any(), {'title': 'أ'}));
    await cubit.close();
  });

  test('a failure keeps the last good image', () async {
    final cubit = build();
    await cubit.render(const {});
    when(() => repo.previewDocument(any(), any())).thenAnswer((_) async => const Left(ServerFailure('أضف اسمًا')));
    await cubit.render(const {});

    expect(cubit.state.status, DocumentPreviewStatus.failure);
    expect(cubit.state.errorMessage, 'أضف اسمًا');
    expect(cubit.state.image, _png);
    await cubit.close();
  });

  test('only the latest render lands', () async {
    final slow = Completer<Either<Failure, DocumentPrintModel>>();
    when(() => repo.previewDocument(any(), any())).thenAnswer((_) => slow.future);
    final cubit = build();
    final first = cubit.render(const {});
    when(() => repo.previewDocument(any(), any())).thenAnswer((_) async => const Left(ServerFailure('newer')));
    await cubit.render(const {});
    slow.complete(const Right(DocumentPrintModel(html: '', fileName: '')));
    await first;

    expect(cubit.state.errorMessage, 'newer');
    await cubit.close();
  });
}

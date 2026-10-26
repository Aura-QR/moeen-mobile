import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/qr_codes/data/models/shared_file_model.dart';
import 'package:moean/features/qr_codes/data/models/shared_files_meta_model.dart';
import 'package:moean/features/qr_codes/data/repositories/shared_files_repository.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_files_list_cubit.dart';

class MockSharedFilesRepository extends Mock implements SharedFilesRepository {}

void main() {
  late MockSharedFilesRepository mockRepo;
  late SharedFilesListCubit cubit;

  const testFile1 = SharedFileModel(
    id: 1,
    fileName: 'file1.pdf',
    mime: 'application/pdf',
    kind: SharedFileKind.pdf,
    byteSize: 1000,
    shareUrl: 'https://haderedu.com/f/1',
  );

  const testFile2 = SharedFileModel(
    id: 2,
    fileName: 'file2.png',
    mime: 'image/png',
    kind: SharedFileKind.image,
    byteSize: 2000,
    shareUrl: 'https://haderedu.com/f/2',
  );

  const testMeta = SharedFilesMetaModel(
    usedBytes: 3000,
    quotaBytes: 10000,
  );

  setUp(() {
    mockRepo = MockSharedFilesRepository();
    cubit = SharedFilesListCubit(repository: mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('SharedFilesListCubit', () {
    test('load fetches files and meta successfully', () async {
      when(() => mockRepo.getFiles()).thenAnswer((_) async => const Right(
            (files: [testFile1, testFile2], meta: testMeta),
          ));

      await cubit.load();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.files.length, 2);
      expect(cubit.state.meta.usedBytes, 3000);
      expect(cubit.state.error, isNull);
    });

    test('load emits error on failure', () async {
      when(() => mockRepo.getFiles()).thenAnswer(
          (_) async => const Left(ServerFailure('network_error')));

      await cubit.load();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error, 'network_error');
    });

    test('extend replaces the file in state with updated file', () async {
      when(() => mockRepo.getFiles()).thenAnswer((_) async => const Right(
            (files: [testFile1, testFile2], meta: testMeta),
          ));
      await cubit.load();

      const extendedFile1 = SharedFileModel(
        id: 1,
        fileName: 'file1.pdf',
        mime: 'application/pdf',
        kind: SharedFileKind.pdf,
        byteSize: 1000,
        shareUrl: 'https://haderedu.com/f/1',
        isExpired: false,
      );

      when(() => mockRepo.update(1, expiresInDays: 30))
          .thenAnswer((_) async => const Right(extendedFile1));

      const reopenedMeta = SharedFilesMetaModel(usedBytes: 4000, quotaBytes: 10000);
      when(() => mockRepo.getFiles()).thenAnswer((_) async => const Right(
            (files: [extendedFile1, testFile2], meta: reopenedMeta),
          ));

      await cubit.extend(1, 30);

      expect(cubit.state.files.first, extendedFile1);
      expect(cubit.state.meta, reopenedMeta);
    });

    test('delete removes the row and reloads meta', () async {
      when(() => mockRepo.getFiles()).thenAnswer((_) async => const Right(
            (files: [testFile1, testFile2], meta: testMeta),
          ));
      await cubit.load();

      when(() => mockRepo.delete(1)).thenAnswer((_) async => const Right(unit));

      const updatedMeta = SharedFilesMetaModel(
        usedBytes: 2000,
        quotaBytes: 10000,
      );
      when(() => mockRepo.getFiles()).thenAnswer((_) async => const Right(
            (files: [testFile2], meta: updatedMeta),
          ));

      await cubit.delete(1);

      expect(cubit.state.files.length, 1);
      expect(cubit.state.files.first.id, 2);
      expect(cubit.state.meta.usedBytes, 2000);
    });

    test('openQr loads file details and returns it', () async {
      const detailedFile = SharedFileModel(
        id: 1,
        fileName: 'file1.pdf',
        mime: 'application/pdf',
        kind: SharedFileKind.pdf,
        byteSize: 1000,
        shareUrl: 'https://haderedu.com/f/1',
        qrPng: 'data:image/png;base64,abc',
      );

      when(() => mockRepo.getFile(1))
          .thenAnswer((_) async => const Right(detailedFile));

      final result = await cubit.openQr(1);

      expect(result, detailedFile);
      expect(cubit.state.selectedFile, detailedFile);
    });
  });
}

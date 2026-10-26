import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/qr_codes/data/models/shared_file_model.dart';
import 'package:moean/features/qr_codes/data/models/shared_files_meta_model.dart';
import 'package:moean/features/qr_codes/data/repositories/shared_files_repository.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_file_upload_cubit.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_file_upload_state.dart';

class MockSharedFilesRepository extends Mock implements SharedFilesRepository {}
class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

class FakeDevicePickedPath extends Fake implements DevicePickedPath {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDevicePickedPath());
  });

  late MockSharedFilesRepository mockRepo;
  late MockDeviceFilePicker mockPicker;
  late SharedFileUploadCubit cubit;

  const testMeta = SharedFilesMetaModel(
    usedBytes: 1000,
    quotaBytes: 10000,
    maxFileBytes: 5000,
    expiryDays: [7, 30, 90, 365],
    defaultExpiryDays: 30,
    types: [
      SharedFileTypeModel(mime: 'application/pdf', ext: 'pdf', kind: 'pdf'),
    ],
  );

  setUp(() {
    mockRepo = MockSharedFilesRepository();
    mockPicker = MockDeviceFilePicker();

    when(() => mockRepo.getFiles()).thenAnswer((_) async => const Right(
          (files: [], meta: testMeta),
        ));

    cubit = SharedFileUploadCubit(
      repository: mockRepo,
      filePicker: mockPicker,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('SharedFileUploadCubit', () {
    test('loadMeta sets meta and ready status', () async {
      await cubit.loadMeta();

      expect(cubit.state.status, SharedFileUploadStatus.ready);
      expect(cubit.state.meta, testMeta);
      expect(cubit.state.expiryDays, 30);
    });

    test('refuses unsupported extension before any network call', () async {
      await cubit.loadMeta();

      const invalidFile = DevicePickedPath(
        path: '/path/file.exe',
        name: 'file.exe',
        byteSize: 100,
      );
      when(() => mockPicker.pickFilePath(any()))
          .thenAnswer((_) async => invalidFile);

      await cubit.pickFileFromDevice();

      expect(cubit.state.error, 'qr_error_type');
      expect(cubit.state.file, isNull);
      verifyNever(() => mockRepo.upload(
            file: any(named: 'file'),
            mime: any(named: 'mime'),
          ));
    });

    test('refuses file exceeding maxFileBytes before any network call', () async {
      await cubit.loadMeta();

      const tooBigFile = DevicePickedPath(
        path: '/path/big.pdf',
        name: 'big.pdf',
        byteSize: 6000, // max is 5000
      );
      when(() => mockPicker.pickFilePath(any()))
          .thenAnswer((_) async => tooBigFile);

      await cubit.pickFileFromDevice();

      expect(cubit.state.error, 'qr_error_too_big');
      expect(cubit.state.file, isNull);
      verifyNever(() => mockRepo.upload(
            file: any(named: 'file'),
            mime: any(named: 'mime'),
          ));
    });

    test('refuses file exceeding remaining quota before any network call', () async {
      const quotaMeta = SharedFilesMetaModel(
        usedBytes: 8000,
        quotaBytes: 10000,
        maxFileBytes: 5000,
        types: [
          SharedFileTypeModel(mime: 'application/pdf', ext: 'pdf', kind: 'pdf'),
        ],
      );
      when(() => mockRepo.getFiles()).thenAnswer((_) async => const Right(
            (files: [], meta: quotaMeta),
          ));
      await cubit.loadMeta();

      const fileOverQuota = DevicePickedPath(
        path: '/path/doc.pdf',
        name: 'doc.pdf',
        byteSize: 3000, // 3000 > 2000 remaining
      );
      when(() => mockPicker.pickFilePath(any()))
          .thenAnswer((_) async => fileOverQuota);

      await cubit.pickFileFromDevice();

      expect(cubit.state.error, 'qr_error_quota');
      expect(cubit.state.file, isNull);
      verifyNever(() => mockRepo.upload(
            file: any(named: 'file'),
            mime: any(named: 'mime'),
          ));
    });

    test('upload success emits done and result', () async {
      await cubit.loadMeta();

      const validFile = DevicePickedPath(
        path: '/path/lesson.pdf',
        name: 'lesson.pdf',
        byteSize: 1000,
      );
      when(() => mockPicker.pickFilePath(any()))
          .thenAnswer((_) async => validFile);

      await cubit.pickFileFromDevice();

      const uploadedModel = SharedFileModel(
        id: 1,
        fileName: 'lesson.pdf',
        mime: 'application/pdf',
        kind: SharedFileKind.pdf,
        byteSize: 1000,
        shareUrl: 'https://haderedu.com/f/1',
      );

      when(() => mockRepo.upload(
            file: validFile,
            mime: 'application/pdf',
            title: any(named: 'title'),
            expiresInDays: any(named: 'expiresInDays'),
            onProgress: any(named: 'onProgress'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer((_) async => const Right(uploadedModel));

      await cubit.upload();

      expect(cubit.state.status, SharedFileUploadStatus.done);
      expect(cubit.state.result, uploadedModel);
    });

    test('upload failure keeps the file so user can retry', () async {
      await cubit.loadMeta();

      const validFile = DevicePickedPath(
        path: '/path/lesson.pdf',
        name: 'lesson.pdf',
        byteSize: 1000,
      );
      when(() => mockPicker.pickFilePath(any()))
          .thenAnswer((_) async => validFile);
      await cubit.pickFileFromDevice();

      when(() => mockRepo.upload(
            file: validFile,
            mime: 'application/pdf',
            title: any(named: 'title'),
            expiresInDays: any(named: 'expiresInDays'),
            onProgress: any(named: 'onProgress'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer((_) async => const Left(ServerFailure('upload_failed')));

      await cubit.upload();

      expect(cubit.state.status, SharedFileUploadStatus.failed);
      expect(cubit.state.error, 'upload_failed');
      expect(cubit.state.file, validFile);
    });

    test('picking before the limits loaded loads them first', () async {
      const validFile = DevicePickedPath(
        path: '/path/lesson.pdf',
        name: 'lesson.pdf',
        byteSize: 1000,
      );
      when(() => mockPicker.pickFilePath(any()))
          .thenAnswer((_) async => validFile);

      await cubit.pickFileFromDevice();

      verify(() => mockRepo.getFiles()).called(1);
      verify(() => mockPicker.pickFilePath(['pdf'])).called(1);
      expect(cubit.state.file, validFile);
    });

    test('does not open the picker when the limits cannot load', () async {
      when(() => mockRepo.getFiles())
          .thenAnswer((_) async => const Left(ServerFailure('network_error')));

      await cubit.pickFileFromDevice();

      verifyNever(() => mockPicker.pickFilePath(any()));
      expect(cubit.state.error, 'network_error');
    });
  });
}

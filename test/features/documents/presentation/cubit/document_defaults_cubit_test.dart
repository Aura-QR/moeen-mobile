import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_defaults_cubit.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

const _resolved = DocumentDefaultsModel(
  texts: {
    DocumentHeaderField.teacherName: 'سارة أحمد',
    DocumentHeaderField.schoolName: 'ابتدائية الأمل',
  },
  genderForm: DocumentGenderForm.female,
  logos: {DocumentLogoSlot.right: 'documents/12/uploads/old.png'},
);

void main() {
  late MockDocumentsRepository repo;
  late MockDeviceFilePicker picker;
  late DocumentDefaultsCubit cubit;

  setUpAll(() {
    registerFallbackValue(const DocumentDefaultsModel());
    registerFallbackValue(DevicePickedFile(bytes: Uint8List(0), name: 'x', mime: null));
  });

  setUp(() {
    repo = MockDocumentsRepository();
    picker = MockDeviceFilePicker();
    cubit = DocumentDefaultsCubit(repository: repo, filePicker: picker);
    when(() => repo.getDefaults()).thenAnswer((_) async => const Right(_resolved));
  });

  tearDown(() => cubit.close());

  test('load prefills the form from resolved', () async {
    await cubit.load();

    expect(cubit.state.status, DocumentDefaultsStatus.success);
    expect(cubit.controllers[DocumentHeaderField.teacherName]!.text, 'سارة أحمد');
    expect(cubit.controllers[DocumentHeaderField.schoolName]!.text, 'ابتدائية الأمل');
    expect(cubit.controllers[DocumentHeaderField.principalName]!.text, isEmpty);
    expect(cubit.state.genderForm, DocumentGenderForm.female);
    expect(cubit.state.logos[DocumentLogoSlot.right], 'documents/12/uploads/old.png');
  });

  test('load failure keeps the message', () async {
    when(() => repo.getDefaults()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    await cubit.load();

    expect(cubit.state.status, DocumentDefaultsStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
  });

  test('save sends the whole form, trimmed', () async {
    when(() => repo.saveDefaults(any())).thenAnswer((_) async => const Right(_resolved));
    await cubit.load();
    cubit.controllers[DocumentHeaderField.principalName]!.text = '  أ. نورة  ';
    cubit.controllers[DocumentHeaderField.schoolName]!.text = '';
    cubit.setRegionCalendar(DocumentRegionCalendar.western);
    await cubit.save();

    final sent = verify(() => repo.saveDefaults(captureAny())).captured.single as DocumentDefaultsModel;
    expect(sent.text(DocumentHeaderField.principalName), 'أ. نورة');
    expect(sent.texts.containsKey(DocumentHeaderField.schoolName), isFalse);
    expect(sent.regionCalendar, DocumentRegionCalendar.western);
    expect(sent.genderForm, DocumentGenderForm.female);
    expect(cubit.state.saved, isTrue);
  });

  test('save failure shows the API message', () async {
    when(() => repo.saveDefaults(any())).thenAnswer((_) async => const Left(ServerFailure('اسم المدرسة طويل')));
    await cubit.load();
    await cubit.save();

    expect(cubit.state.saved, isFalse);
    expect(cubit.state.feedback?.message, 'اسم المدرسة طويل');
    expect(cubit.state.isSaving, isFalse);
  });

  test('pickLogo uploads and keeps the path and a preview', () async {
    final file = DevicePickedFile(bytes: Uint8List.fromList([1, 2]), name: 'logo.png', mime: 'image/png');
    when(() => picker.pick(DeviceFileSource.gallery)).thenAnswer((_) async => file);
    when(() => repo.uploadImage(file)).thenAnswer((_) async => const Right('documents/12/uploads/new.png'));
    await cubit.load();
    await cubit.pickLogo(DocumentLogoSlot.left, DeviceFileSource.gallery);

    expect(cubit.state.logos[DocumentLogoSlot.left], 'documents/12/uploads/new.png');
    expect(cubit.state.previews[DocumentLogoSlot.left], file.bytes);
    expect(cubit.state.uploadingSlot, isNull);
  });

  test('pickLogo rejects a PDF without uploading', () async {
    when(() => picker.pick(DeviceFileSource.gallery)).thenAnswer(
      (_) async => DevicePickedFile(bytes: Uint8List(10), name: 'a.pdf', mime: 'application/pdf'),
    );
    await cubit.pickLogo(DocumentLogoSlot.left, DeviceFileSource.gallery);

    verifyNever(() => repo.uploadImage(any()));
    expect(cubit.state.feedback?.message, 'document_unsupported_image');
  });

  test('removeLogo clears the slot', () async {
    await cubit.load();
    cubit.removeLogo(DocumentLogoSlot.right);

    expect(cubit.state.logos, isEmpty);
  });
}

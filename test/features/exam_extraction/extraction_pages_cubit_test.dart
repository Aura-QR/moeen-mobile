import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_cubit.dart';

class MockImagePicker extends Mock implements ImagePicker {}
class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

void main() {
  late MockImagePicker mockImagePicker;
  late MockDeviceFilePicker mockFilePicker;
  late ExtractionPagesCubit cubit;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockFilePicker = MockDeviceFilePicker();
    cubit = ExtractionPagesCubit(
      imagePicker: mockImagePicker,
      filePicker: mockFilePicker,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ExtractionPagesCubit', () {
    test('initial state is empty and canStart is false', () {
      expect(cubit.state.pages, isEmpty);
      expect(cubit.state.count, 10);
      expect(cubit.state.canStart, isFalse);
    });

    test('setCount clamps value between 1 and 40', () {
      cubit.setCount(0);
      expect(cubit.state.count, 1);

      cubit.setCount(50);
      expect(cubit.state.count, 40);

      cubit.setCount(15);
      expect(cubit.state.count, 15);
    });

    test('setNotes limits string to 500 characters', () {
      final longNote = 'A' * 600;
      cubit.setNotes(longNote);
      expect(cubit.state.notes?.length, 500);
    });

    test('addFromCamera adds photo when valid', () async {
      final fakeBytes = Uint8List.fromList([1, 2, 3]);
      final xFile = XFile.fromData(fakeBytes, path: 'test.jpg', name: 'test.jpg');

      when(() => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1600,
            maxHeight: 1600,
            imageQuality: 85,
          )).thenAnswer((_) async => xFile);

      await cubit.addFromCamera();

      expect(cubit.state.pages.length, 1);
      expect(cubit.state.pages.first.name, 'test.jpg');
      expect(cubit.state.canStart, isTrue);
      expect(cubit.state.error, isNull);
    });

    test('addFromCamera refuses photo larger than 4 MB', () async {
      final bigBytes = Uint8List(5 * 1024 * 1024); // 5 MB
      final xFile = XFile.fromData(bigBytes, name: 'big.jpg');

      when(() => mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1600,
            maxHeight: 1600,
            imageQuality: 85,
          )).thenAnswer((_) async => xFile);

      await cubit.addFromCamera();

      expect(cubit.state.pages, isEmpty);
      expect(cubit.state.error, 'exam_extract_photo_too_big');
    });

    test('pickPdf replaces pages and accepts file under 10 MB', () async {
      final pdfBytes = Uint8List.fromList([1, 2, 3, 4]);
      final pickedPdf = DevicePickedFile(
        bytes: pdfBytes,
        name: 'exam.pdf',
        mime: 'application/pdf',
      );

      when(() => mockFilePicker.pick(DeviceFileSource.pdf))
          .thenAnswer((_) async => pickedPdf);

      await cubit.pickPdf();

      expect(cubit.state.pages.length, 1);
      expect(cubit.state.pages.first.isPdf, isTrue);
      expect(cubit.state.pages.first.name, 'exam.pdf');
    });

    test('pickPdf refuses PDF larger than 10 MB', () async {
      final bigPdfBytes = Uint8List(11 * 1024 * 1024); // 11 MB
      final pickedPdf = DevicePickedFile(
        bytes: bigPdfBytes,
        name: 'big_exam.pdf',
        mime: 'application/pdf',
      );

      when(() => mockFilePicker.pick(DeviceFileSource.pdf))
          .thenAnswer((_) async => pickedPdf);

      await cubit.pickPdf();

      expect(cubit.state.pages, isEmpty);
      expect(cubit.state.error, 'exam_extract_pdf_too_big');
    });

    test('addFromCamera refuses when a PDF is already picked', () async {
      final pdfBytes = Uint8List.fromList([1, 2, 3]);
      when(() => mockFilePicker.pick(DeviceFileSource.pdf)).thenAnswer(
        (_) async => DevicePickedFile(
          bytes: pdfBytes,
          name: 'doc.pdf',
          mime: 'application/pdf',
        ),
      );

      await cubit.pickPdf();
      await cubit.addFromCamera();

      expect(cubit.state.error, 'exam_extract_no_mix');
      expect(cubit.state.pages.length, 1);
    });
  });
}

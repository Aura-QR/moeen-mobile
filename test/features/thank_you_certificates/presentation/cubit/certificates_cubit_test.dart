import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/student_picker_result.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/thank_you_certificates/data/models/certificates_catalogue_model.dart';
import 'package:moean/features/thank_you_certificates/data/repositories/certificates_repository.dart';
import 'package:moean/features/thank_you_certificates/presentation/cubit/certificates_cubit.dart';

class MockCertificatesRepository extends Mock implements CertificatesRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

class MockClassesRepository extends Mock implements ClassesRepository {}

class MockDeviceFilePicker extends Mock implements DeviceFilePicker {}

const _catalogue = CertificatesCatalogueModel(
  reasons: [
    CertificateReasonModel(
      key: 'excellence',
      label: 'التفوق الدراسي',
      title: 'شهادة تفوق',
      texts: {'male': 'للطالب {name}', 'female': 'للطالبة {name}'},
    ),
    CertificateReasonModel(
      key: 'improvement',
      label: 'التحسن',
      title: 'شهادة تحسن',
      texts: {'male': 'تحسن الطالب {name}', 'female': 'تحسن الطالبة {name}'},
    ),
  ],
  designs: [CertificateDesignModel(key: 'classic_green', label: 'كلاسيكي أخضر', imageUrl: '')],
  limits: CertificatesLimits(names: 3),
);

DocumentModel _saved(int id, {Map<String, dynamic> input = const {}}) => DocumentModel(
  id: id,
  type: DocumentTypes.certificates,
  title: 'شهادات',
  status: DocumentStatus.draft,
  input: input,
);

void main() {
  late MockCertificatesRepository certificates;
  late MockDocumentsRepository documents;
  late MockClassesRepository classes;
  late MockDeviceFilePicker picker;

  Future<CertificatesCubit> loaded({int? documentId}) async {
    final cubit = CertificatesCubit(
      documentId: documentId,
      certificatesRepository: certificates,
      documentsRepository: documents,
      classesRepository: classes,
      filePicker: picker,
      today: () => DateTime(2026, 10, 22),
    );
    await cubit.load();
    return cubit;
  }

  Map<String, dynamic> capturedCreateInput() =>
      verify(
            () => documents.createDocument(
              type: DocumentTypes.certificates,
              input: captureAny(named: 'input'),
              status: any(named: 'status'),
            ),
          ).captured.single
          as Map<String, dynamic>;

  setUpAll(() => registerFallbackValue(DevicePickedFile(bytes: Uint8List(0), name: '', mime: null)));

  setUp(() {
    certificates = MockCertificatesRepository();
    documents = MockDocumentsRepository();
    classes = MockClassesRepository();
    picker = MockDeviceFilePicker();
    when(() => certificates.getCatalogue()).thenAnswer((_) async => const Right(_catalogue));
    when(
      () => documents.getDefaults(),
    ).thenAnswer((_) async => const Right(DocumentDefaultsModel(genderForm: DocumentGenderForm.female)));
    when(
      () => documents.createDocument(
        type: any(named: 'type'),
        input: any(named: 'input'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right(_saved(50)));
  });

  test('load preselects the first reason and design, the teacher\'s audience, and today', () async {
    final cubit = await loaded();

    expect(cubit.state.reason, 'excellence');
    expect(cubit.state.design, 'classic_green');
    expect(cubit.state.audience, 'female');
    expect(cubit.state.date, DateTime(2026, 10, 22));
    expect(cubit.textController.text, 'للطالبة {name}');
    expect(cubit.isTextEdited, isFalse);
    await cubit.close();
  });

  test('load fails when the catalogue fails', () async {
    when(() => certificates.getCatalogue()).thenAnswer((_) async => const Left(ServerFailure('network_error')));
    final cubit = await loaded();

    expect(cubit.state.status, CertificatesStatus.failure);
    await cubit.close();
  });

  test('changing the reason refills untouched text but keeps edited text', () async {
    final cubit = await loaded();
    cubit.setReason('improvement');
    expect(cubit.titleController.text, 'شهادة تحسن');
    expect(cubit.textController.text, 'تحسن الطالبة {name}');

    cubit.textController.text = 'نصي الخاص {name}';
    cubit.setAudience('male');
    expect(cubit.textController.text, 'نصي الخاص {name}');
    expect(cubit.titleController.text, 'شهادة تحسن');
    expect(cubit.isTextEdited, isTrue);

    cubit.restoreDefaultText();
    expect(cubit.textController.text, 'تحسن الطالب {name}');
    await cubit.close();
  });

  test('«إدراج الاسم» puts {name} at the cursor', () async {
    final cubit = await loaded();
    cubit.textController.value = const TextEditingValue(
      text: 'أبارك  نجاحه',
      selection: TextSelection.collapsed(offset: 6),
    );
    cubit.insertNamePlaceholder();

    expect(cubit.textController.text, 'أبارك {name} نجاحه');
    expect(cubit.textController.selection.baseOffset, 12);
    await cubit.close();
  });

  test('names from a class, removed one by one, capped at the limit', () async {
    final cubit = await loaded();
    cubit.setNames(const StudentPickerResult(classId: 3, students: ['ريم', 'سارة', 'نورة', 'هند']));
    expect(cubit.state.names, ['ريم', 'سارة', 'نورة']);
    expect(cubit.state.classId, 3);

    cubit.removeName(1);
    expect(cubit.state.names, ['ريم', 'نورة']);

    cubit.addImportedNames(['هند', 'مها']);
    expect(cubit.state.names, ['ريم', 'نورة', 'هند']);
    expect(cubit.state.classId, isNull);
    await cubit.close();
  });

  test('Excel names come back for review', () async {
    when(
      () => picker.pickSpreadsheet(),
    ).thenAnswer((_) async => DevicePickedFile(bytes: Uint8List(10), name: 'names.xlsx', mime: null));
    when(() => classes.importNames(any())).thenAnswer((_) async => const Right(['ريم']));
    final cubit = await loaded();
    final states = <CertificatesState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.importFromFile();
    await pumpEventQueue();

    expect(states.last.importedNames, ['ريم']);
    await sub.cancel();
    await cubit.close();
  });

  test('the preview is one certificate: the given name, else the first, else a sample', () async {
    final cubit = await loaded();
    expect(cubit.previewInput(fallbackName: 'اسم الطالب')!['names'], ['اسم الطالب']);

    cubit.setNames(const StudentPickerResult(students: ['ريم', 'سارة']));
    expect(cubit.previewInput(fallbackName: 'x')!['names'], ['ريم']);
    expect(cubit.previewInput(name: 'سارة', fallbackName: 'x')!['names'], ['سارة']);
    await cubit.close();
  });

  test('each change bumps the revision the preview follows', () async {
    final cubit = await loaded();
    final revision = cubit.state.revision;
    cubit.setDesign('classic_green');
    cubit.titleController.text = 'عنوان';

    expect(cubit.state.revision, revision + 2);
    await cubit.close();
  });

  test('save needs a name; default texts are sent empty, edited ones as typed', () async {
    final cubit = await loaded();
    await cubit.save();
    verifyNever(
      () => documents.createDocument(
        type: any(named: 'type'),
        input: any(named: 'input'),
        status: any(named: 'status'),
      ),
    );

    cubit.setNames(const StudentPickerResult(students: ['ريم']));
    cubit.titleController.text = 'شهادة شكر خاصة';
    await cubit.save();

    final input = capturedCreateInput();
    expect(input['names'], ['ريم']);
    expect(input['title'], 'شهادة شكر خاصة');
    expect(input.containsKey('text'), isFalse);
    expect(input['audience'], 'female');
    expect(cubit.state.documentId, 50);
    await cubit.close();
  });

  test('the portfolio item follows the reason', () async {
    final cubit = await loaded();
    expect(cubit.portfolioItemKey, 'learning_environment');

    cubit.setReason(CertificatesCubit.improvementReason);
    expect(cubit.portfolioItemKey, 'learner_results');
    await cubit.close();
  });

  test('reopening restores every step', () async {
    when(() => documents.getDocument(9)).thenAnswer(
      (_) async => Right(
        _saved(
          9,
          input: {
            'names': ['ريم', 'سارة'],
            'class_id': 3,
            'reason': 'improvement',
            'design': 'classic_green',
            'audience': 'male',
            'text': 'نص خاص {name}',
            'header': {'school_name': 'مدرسة النور'},
          },
        ),
      ),
    );
    final cubit = await loaded(documentId: 9);

    expect(cubit.state.names, ['ريم', 'سارة']);
    expect(cubit.state.classId, 3);
    expect(cubit.state.reason, 'improvement');
    expect(cubit.state.audience, 'male');
    expect(cubit.state.date, isNull);
    expect(cubit.titleController.text, 'شهادة تحسن');
    expect(cubit.textController.text, 'نص خاص {name}');
    expect(cubit.state.isOverridingHeader, isTrue);
    await cubit.close();
  });
}

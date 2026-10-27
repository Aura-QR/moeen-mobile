import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_map_editor_cubit.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

void main() {
  late MockDocumentsRepository documents;

  setUp(() {
    documents = MockDocumentsRepository();
    when(
      () => documents.getDefaults(),
    ).thenAnswer((_) async => const Right(DocumentDefaultsModel()));
  });

  test(
    'creates document on first save and updates on subsequent save',
    () async {
      final cubit = ConceptMapEditorCubit(
        documentsRepository: documents,
        initialInput: ConceptMapInput.blank(
          title: 'خريطة الخلية',
          mainConcept: 'الخلية',
        ),
      );
      addTearDown(cubit.close);

      when(
        () => documents.createDocument(
          type: DocumentTypes.conceptMap,
          input: any(named: 'input'),
          status: DocumentStatus.draft,
          keepFieldErrors: true,
        ),
      ).thenAnswer(
        (_) async => const Right(
          DocumentModel(
            id: 55,
            type: DocumentTypes.conceptMap,
            title: 'خريطة الخلية',
            status: DocumentStatus.draft,
          ),
        ),
      );

      when(
        () => documents.updateDocument(
          55,
          any(),
          status: DocumentStatus.draft,
          keepFieldErrors: true,
        ),
      ).thenAnswer(
        (_) async => const Right(
          DocumentModel(
            id: 55,
            type: DocumentTypes.conceptMap,
            title: 'خريطة الخلية المعدلة',
            status: DocumentStatus.draft,
          ),
        ),
      );

      await cubit.load();
      await cubit.save();
      expect(cubit.state.documentId, 55);
      expect(cubit.state.isDirty, isFalse);

      cubit.setLayout(ConceptMapLayout.radial);
      await cubit.save();
      verify(
        () => documents.updateDocument(
          55,
          any(),
          status: DocumentStatus.draft,
          keepFieldErrors: true,
        ),
      ).called(1);
    },
  );

  test(
    '422 validation error on nodes.N opens that concept sheet with error message',
    () async {
      final initial = ConceptMapInput.blank(
        title: 'المادة',
        mainConcept: 'المادة',
      ).addChild('n1', id: 'n2', text: 'فرع ثانٍ');
      final cubit = ConceptMapEditorCubit(
        documentsRepository: documents,
        initialInput: initial,
      );
      addTearDown(cubit.close);

      when(
        () => documents.createDocument(
          type: DocumentTypes.conceptMap,
          input: any(named: 'input'),
          status: DocumentStatus.draft,
          keepFieldErrors: true,
        ),
      ).thenAnswer(
        (_) async => const Left(
          ValidationFailure('بيانات غير صالحة', {
            'nodes.1.text': ['النص غير مسموح'],
          }),
        ),
      );

      await cubit.load();
      await cubit.save();

      expect(cubit.state.openNodeSheetId, 'n2');
      expect(cubit.state.nodeErrors['n2'], 'النص غير مسموح');
    },
  );
}

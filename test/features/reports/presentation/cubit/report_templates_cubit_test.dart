import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/reports/data/models/report_catalogue_model.dart';
import 'package:moean/features/reports/data/repositories/reports_repository.dart';
import 'package:moean/features/reports/presentation/cubit/report_templates_cubit.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

class MockDocumentsRepository extends Mock implements DocumentsRepository {}

void main() {
  late MockReportsRepository reports;
  late MockDocumentsRepository documents;
  late ReportTemplatesCubit cubit;

  final catalogue = ReportCatalogueModel.fromJson({
    'templates': [
      {'key': 'blank', 'label': 'تقرير فارغ', 'description': ''},
    ],
  });
  const saved = DocumentModel(id: 3, type: DocumentTypes.report, title: 'تقرير', status: DocumentStatus.draft);

  setUp(() {
    reports = MockReportsRepository();
    documents = MockDocumentsRepository();
    cubit = ReportTemplatesCubit(reports: reports, documents: documents);
    when(() => reports.getCatalogue()).thenAnswer((_) async => Right(catalogue));
    when(() => documents.getDocuments(type: DocumentTypes.report)).thenAnswer(
      (_) async => const Right(DocumentsPageModel(items: [saved], currentPage: 1, lastPage: 1, total: 1)),
    );
  });

  tearDown(() => cubit.close());

  test('load shows the templates and the saved reports', () async {
    await cubit.load();

    expect(cubit.state.status, ReportTemplatesStatus.success);
    expect(cubit.state.catalogue!.templates.single.key, 'blank');
    expect(cubit.state.saved.single.id, 3);
  });

  test('the templates still show when the saved list fails', () async {
    when(() => documents.getDocuments(type: DocumentTypes.report))
        .thenAnswer((_) async => const Left(ServerFailure('network_error')));

    await cubit.load();

    expect(cubit.state.status, ReportTemplatesStatus.success);
    expect(cubit.state.saved, isEmpty);
  });

  test('a catalogue failure shows the error', () async {
    when(() => reports.getCatalogue()).thenAnswer((_) async => const Left(ServerFailure('network_error')));

    await cubit.load();

    expect(cubit.state.status, ReportTemplatesStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
  });
}

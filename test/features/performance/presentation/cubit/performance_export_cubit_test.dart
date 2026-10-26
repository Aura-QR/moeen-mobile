import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/performance/presentation/cubit/performance_export_cubit.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  late MockPortfolioRepository repo;
  late PerformanceExportCubit cubit;

  setUp(() {
    repo = MockPortfolioRepository();
    cubit = PerformanceExportCubit(portfolioId: 7, repository: repo);
  });

  tearDown(() => cubit.close());

  test('export sends the options and returns the document', () async {
    when(() => repo.exportPerformanceFile(7, includeRatings: false, theme: 'blue'))
        .thenAnswer((_) async => const Right(55));

    cubit.setIncludeRatings(false);
    cubit.setTheme(DocumentTheme.blue);
    await cubit.export();

    expect(cubit.state.documentId, 55);
    expect(cubit.state.isExporting, isFalse);
  });

  test('ratings are included with the teal theme by default', () async {
    when(() => repo.exportPerformanceFile(7, includeRatings: true, theme: 'teal'))
        .thenAnswer((_) async => const Right(55));

    await cubit.export();

    verify(() => repo.exportPerformanceFile(7, includeRatings: true, theme: 'teal')).called(1);
  });

  test('a failure shows its message', () async {
    when(() => repo.exportPerformanceFile(7, includeRatings: true, theme: 'teal'))
        .thenAnswer((_) async => const Left(ServerFailure('وصلت للحد الأقصى لعدد المستندات المحفوظة.')));

    await cubit.export();

    expect(cubit.state.documentId, isNull);
    expect(cubit.state.errorMessage, 'وصلت للحد الأقصى لعدد المستندات المحفوظة.');
  });
}

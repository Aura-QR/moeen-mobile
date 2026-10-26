import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/performance/presentation/cubit/performance_cubit.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

import '../../../portfolio/data/models/performance_fixture.dart';

class MockPortfolioRepository extends Mock implements PortfolioRepository {}

void main() {
  late MockPortfolioRepository repo;
  late PerformanceCubit cubit;

  PerformanceModel model({int? selfRating = 4}) => PerformanceModel.fromJson(performanceJson(selfRating: selfRating));

  setUp(() {
    repo = MockPortfolioRepository();
    cubit = PerformanceCubit(portfolioId: 7, repository: repo);
    when(() => repo.getPerformance(7)).thenAnswer((_) async => Right(model()));
  });

  tearDown(() => cubit.close());

  test('load shows the view', () async {
    await cubit.load();

    expect(cubit.state.status, PerformanceStatus.success);
    expect(cubit.state.performance!.items, hasLength(2));
  });

  test('load failure shows the error', () async {
    when(() => repo.getPerformance(7)).thenAnswer((_) async => const Left(ServerFailure('network_error')));

    await cubit.load();

    expect(cubit.state.status, PerformanceStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
  });

  test('a refresh failure after loading keeps the view', () async {
    await cubit.load();
    when(() => repo.getPerformance(7)).thenAnswer((_) async => const Left(ServerFailure('network_error')));

    await cubit.refresh();

    expect(cubit.state.status, PerformanceStatus.success);
    expect(cubit.state.feedback?.message, 'network_error');
  });

  test('rating saves the new value and reloads the summary', () async {
    await cubit.load();
    when(() => repo.setSelfRating(7, 31, 2)).thenAnswer((_) async => const Right(unit));
    when(() => repo.getPerformance(7)).thenAnswer((_) async => Right(model(selfRating: 2)));

    await cubit.rate(cubit.state.performance!.itemById(31)!, 2);

    verify(() => repo.setSelfRating(7, 31, 2)).called(1);
    expect(cubit.state.performance!.itemById(31)!.selfRating, 2);
    expect(cubit.state.ratingItemId, isNull);
  });

  test('tapping the current rating clears it', () async {
    await cubit.load();
    when(() => repo.setSelfRating(7, 31, null)).thenAnswer((_) async => const Right(unit));
    when(() => repo.getPerformance(7)).thenAnswer((_) async => Right(model(selfRating: null)));

    await cubit.rate(cubit.state.performance!.itemById(31)!, 4);

    verify(() => repo.setSelfRating(7, 31, null)).called(1);
    expect(cubit.state.performance!.itemById(31)!.selfRating, isNull);
  });

  test('a failed rating goes back to the old value', () async {
    await cubit.load();
    when(() => repo.setSelfRating(7, 31, 1)).thenAnswer((_) async => const Left(ServerFailure('generic_error')));

    await cubit.rate(cubit.state.performance!.itemById(31)!, 1);

    expect(cubit.state.performance!.itemById(31)!.selfRating, 4);
    expect(cubit.state.feedback?.message, 'generic_error');
    expect(cubit.state.ratingItemId, isNull);
  });

  test('items without a weight are not rated', () async {
    await cubit.load();

    await cubit.rate(cubit.state.performance!.itemById(32)!, 3);

    verifyNever(() => repo.setSelfRating(any(), any(), any()));
  });

  test('saveCv sends every CV field, empty ones as null', () async {
    await cubit.load();
    when(() => repo.updateCv(7, any())).thenAnswer((_) async => const Right(unit));

    await cubit.saveCv({'name': ' سارة ', 'rank': '', 'phone': '0500000000'});

    final sent = verify(() => repo.updateCv(7, captureAny())).captured.single as Map<String, String?>;
    expect(sent.keys, PerformanceCvFields.all);
    expect(sent['name'], 'سارة');
    expect(sent['rank'], isNull);
    expect(sent.containsKey('phone'), isFalse);
    expect(cubit.state.isSavingCv, isFalse);
    expect(cubit.state.feedback?.message, 'performance_cv_saved');
  });
}

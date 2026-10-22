import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/grade_analysis/data/models/grade_analysis_result.dart';
import 'package:moean/features/grade_analysis/data/repositories/grade_analysis_repository.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_results_cubit.dart';

class MockGradeAnalysisRepository extends Mock implements GradeAnalysisRepository {}

const _result = GradeAnalysisResult(totalMark: 20, aiInput: {'mean_percent': 70});

void main() {
  late MockGradeAnalysisRepository repo;

  setUp(() {
    repo = MockGradeAnalysisRepository();
    when(() => repo.analyze(any())).thenAnswer((_) async => const Right(_result));
  });

  test('changes in a row are analysed once, after the debounce', () async {
    final cubit = GradeResultsCubit(repo, debounce: const Duration(milliseconds: 20));
    cubit.schedule({'total_mark': 18});
    cubit.schedule({'total_mark': 19});
    cubit.schedule({'total_mark': 20});
    await Future<void>.delayed(const Duration(milliseconds: 60));

    verify(() => repo.analyze({'total_mark': 20})).called(1);
    expect(cubit.state.status, GradeResultsStatus.success);
    expect(cubit.state.aiInput, {'mean_percent': 70});
    await cubit.close();
  });

  test('a 422 shows its message', () async {
    when(() => repo.analyze(any())).thenAnswer((_) async => const Left(ServerFailure('الدرجة أكبر من الدرجة الكلية.')));
    final cubit = GradeResultsCubit(repo);
    await cubit.analyze(const {});

    expect(cubit.state.status, GradeResultsStatus.failure);
    expect(cubit.state.errorMessage, 'الدرجة أكبر من الدرجة الكلية.');
    expect(cubit.state.aiInput, isNull);
    await cubit.close();
  });

  test('waiting drops the pending answer and says what is missing', () async {
    final slow = Completer<Either<Failure, GradeAnalysisResult>>();
    when(() => repo.analyze(any())).thenAnswer((_) => slow.future);
    final cubit = GradeResultsCubit(repo);
    final request = cubit.analyze(const {});
    cubit.wait('grades_issue_total');
    slow.complete(const Right(_result));
    await request;

    expect(cubit.state.status, GradeResultsStatus.waiting);
    expect(cubit.state.issue, 'grades_issue_total');
    await cubit.close();
  });

  test('the last numbers stay while new ones load', () async {
    final cubit = GradeResultsCubit(repo);
    await cubit.analyze(const {});
    final slow = Completer<Either<Failure, GradeAnalysisResult>>();
    when(() => repo.analyze(any())).thenAnswer((_) => slow.future);
    unawaited(cubit.analyze(const {}));

    expect(cubit.state.status, GradeResultsStatus.loading);
    expect(cubit.state.result, same(_result));
    slow.complete(const Right(_result));
    await cubit.close();
  });
}

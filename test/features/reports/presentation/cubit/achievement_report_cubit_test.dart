import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/reports/data/models/achievement_period.dart';
import 'package:moean/features/reports/data/models/achievement_report_model.dart';
import 'package:moean/features/reports/data/repositories/achievement_report_repository.dart';
import 'package:moean/features/reports/presentation/cubit/achievement_report_cubit.dart';

class MockAchievementReportRepository extends Mock implements AchievementReportRepository {}

AchievementReportModel _report({required String from, required String to}) {
  return AchievementReportModel.fromJson({
    'period': 'week',
    'from': from,
    'to': to,
    'totals': {'lessons_prepared': 12, 'exams': 2, 'educational_reports': 1, 'presentations': 3, 'worksheets': 2},
    'by_day': [
      {'date': from, 'lessons_prepared': 3},
    ],
    'lessons': [
      {'id': 501, 'lesson_id': 88, 'title': 'جمل الطرح', 'completed_at': '2026-10-18T09:12:00+03:00'},
    ],
  });
}

void main() {
  late MockAchievementReportRepository repo;
  late AchievementReportCubit cubit;
  final today = DateTime(2026, 10, 21);
  final pdfBytes = Uint8List.fromList([1, 2, 3]);

  setUpAll(() {
    registerFallbackValue(AchievementPeriod.week);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repo = MockAchievementReportRepository();
    cubit = AchievementReportCubit(repo, pdfBuilder: (_) async => pdfBytes, clock: () => today);
  });

  tearDown(() => cubit.close());

  void stubReport(AchievementReportModel report) {
    when(() => repo.getReport(period: any(named: 'period'), date: any(named: 'date')))
        .thenAnswer((_) async => Right(report));
  }

  test('starts on this week', () {
    expect(cubit.state.period, AchievementPeriod.week);
    expect(cubit.state.date, today);
  });

  test('load shows the report and blocks next when the period reaches today', () async {
    stubReport(_report(from: '2026-10-18', to: '2026-10-24'));
    await cubit.load();

    expect(cubit.state.status, AchievementReportStatus.success);
    expect(cubit.state.report!.totals.lessonsPrepared, 12);
    expect(cubit.state.canGoNext, isFalse);
  });

  test('load reports the failure message', () async {
    when(() => repo.getReport(period: any(named: 'period'), date: any(named: 'date')))
        .thenAnswer((_) async => const Left(ServerFailure('network_error')));
    await cubit.load();

    expect(cubit.state.status, AchievementReportStatus.failure);
    expect(cubit.state.errorMessage, 'network_error');
  });

  test('previous moves back a week and allows next again', () async {
    stubReport(_report(from: '2026-10-11', to: '2026-10-17'));
    await cubit.previous();

    expect(cubit.state.date, DateTime(2026, 10, 14));
    verify(() => repo.getReport(period: AchievementPeriod.week, date: DateTime(2026, 10, 14))).called(1);
    expect(cubit.state.canGoNext, isTrue);
  });

  test('next does nothing while the period reaches today', () async {
    await cubit.next();
    verifyNever(() => repo.getReport(period: any(named: 'period'), date: any(named: 'date')));
  });

  test('changePeriod reloads with the new period', () async {
    stubReport(_report(from: '2026-10-01', to: '2026-10-31'));
    await cubit.changePeriod(AchievementPeriod.month);

    expect(cubit.state.period, AchievementPeriod.month);
    verify(() => repo.getReport(period: AchievementPeriod.month, date: today)).called(1);
  });

  test('exportPdf emits the bytes once', () async {
    stubReport(_report(from: '2026-10-18', to: '2026-10-24'));
    await cubit.load();
    await cubit.exportPdf();

    expect(cubit.state.isExporting, isFalse);
    expect(cubit.state.pdfBytes, pdfBytes);
  });

  test('lesson times are read as Saudi wall-clock time', () {
    final lesson = _report(from: '2026-10-18', to: '2026-10-24').lessons.single;
    expect(lesson.completedAt!.hour, 9);
    expect(lesson.completedAt!.minute, 12);
  });
}

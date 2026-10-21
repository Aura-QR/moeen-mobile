import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/reports/data/models/achievement_period.dart';
import 'package:moean/features/reports/data/models/achievement_report_model.dart';
import 'package:moean/features/reports/data/repositories/achievement_report_repository.dart';

part 'achievement_report_state.dart';

/// Builds the PDF bytes; injectable so tests don't need fonts or assets.
typedef AchievementPdfBuilder = Future<Uint8List> Function(AchievementReportModel report);

class AchievementReportCubit extends Cubit<AchievementReportState> {
  static AchievementReportCubit get(BuildContext context) => BlocProvider.of(context);

  AchievementReportCubit(
    this._repo, {
    required AchievementPdfBuilder pdfBuilder,
    DateTime Function()? clock,
  })  : _pdfBuilder = pdfBuilder,
        _clock = clock ?? DateTime.now,
        super(AchievementReportState(period: AchievementPeriod.week, date: (clock ?? DateTime.now)()));

  final AchievementReportRepository _repo;
  final AchievementPdfBuilder _pdfBuilder;
  final DateTime Function() _clock;

  /// Ignores responses from requests that a newer one has replaced.
  int _requestId = 0;

  Future<void> load() async {
    final requestId = ++_requestId;
    emit(state.copyWith(status: AchievementReportStatus.loading));
    final result = await _repo.getReport(period: state.period, date: state.date);
    if (isClosed || requestId != _requestId) return;

    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    result.fold(
      (failure) => emit(state.copyWith(status: AchievementReportStatus.failure, errorMessage: failure.message)),
      (report) => emit(state.copyWith(
        status: AchievementReportStatus.success,
        report: report,
        canGoNext: report.to.isBefore(today),
      )),
    );
  }

  Future<void> changePeriod(AchievementPeriod period) async {
    if (period == state.period) return;
    emit(state.copyWith(period: period));
    await load();
  }

  Future<void> previous() async {
    emit(state.copyWith(date: state.period.shift(state.date, -1)));
    await load();
  }

  Future<void> next() async {
    if (!state.canGoNext) return;
    emit(state.copyWith(date: state.period.shift(state.date, 1)));
    await load();
  }

  Future<void> exportPdf() async {
    final report = state.report;
    if (report == null || state.isExporting) return;
    emit(state.copyWith(isExporting: true));
    try {
      final bytes = await _pdfBuilder(report);
      if (!isClosed) emit(state.copyWith(isExporting: false, pdfBytes: bytes));
    } catch (_) {
      if (!isClosed) emit(state.copyWith(isExporting: false, feedback: 'generic_error'));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/reports/presentation/cubit/report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit() : super(const ReportInitial());

  static ReportCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> generateReport({
    required String reportType,
    required String grade,
    required dynamic subject,
    required List<String> selectedLessons,
  }) async {
    if (!isClosed) emit(const ReportLoading());

    final result = await ApiService.generateEducationalReport(
      reportType: reportType,
      grade: grade,
      subject: subject,
      selectedLessons: selectedLessons,
    );
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) {
          if (error.startsWith('__402__:')) {
            final parts = error.split(':');
            final code = parts.length > 1 ? parts[1] : 'quota_exceeded';
            final msg = parts.length > 2 ? parts.sublist(2).join(':') : 'ترقية الحساب المطلوبة';
            emit(ReportPaymentRequired(message: msg, code: code));
          } else {
            emit(ReportError(message: error));
          }
        }
      },
      (data) {
        if (!isClosed) emit(ReportSuccess(data: data));
      },
    );
  }

  void reset() {
    if (!isClosed) emit(const ReportInitial());
  }
}

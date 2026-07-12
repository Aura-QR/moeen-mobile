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
    emit(const ReportLoading());

    final result = await ApiService.generateEducationalReport(
      reportType: reportType,
      grade: grade,
      subject: subject,
      selectedLessons: selectedLessons,
    );

    result.fold(
      (error) => emit(ReportError(message: error)),
      (data) => emit(ReportSuccess(data: data)),
    );
  }

  void reset() => emit(const ReportInitial());
}

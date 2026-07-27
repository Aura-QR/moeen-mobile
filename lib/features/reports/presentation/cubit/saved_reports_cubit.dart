import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/reports/data/saved_report_model.dart';
import 'package:moean/features/reports/presentation/cubit/saved_reports_state.dart';

class SavedReportsCubit extends Cubit<SavedReportsState> {
  SavedReportsCubit() : super(const SavedReportsInitial());

  static SavedReportsCubit get(BuildContext context) => BlocProvider.of(context);

  String _currentFilter = 'الكل';

  String get currentFilter => _currentFilter;

  Future<void> fetchReports({String? filter}) async {
    if (filter != null) {
      _currentFilter = filter;
    }

    emit(const SavedReportsLoading());

    final String? apiType = (_currentFilter == 'الكل') ? null : _currentFilter;

    final result = await ApiService.getSavedEducationalReports(
      reportType: apiType,
      perPage: 30,
    );

    result.fold(
      (error) => emit(SavedReportsError(message: error)),
      (response) {
        try {
          final List<dynamic> listData = response['data'] is List ? response['data'] : [];
          final reports = listData.map((e) => SavedReportModel.fromJson(e as Map<String, dynamic>)).toList();
          final meta = SavedReportsMeta.fromJson((response['meta'] as Map<String, dynamic>?) ?? {});
          
          emit(SavedReportsSuccess(
            reports: reports,
            meta: meta,
            selectedFilter: _currentFilter,
          ));
        } catch (e) {
          emit(SavedReportsError(message: e.toString()));
        }
      },
    );
  }
}

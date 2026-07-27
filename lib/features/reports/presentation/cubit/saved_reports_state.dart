import 'package:equatable/equatable.dart';
import 'package:moean/features/reports/data/saved_report_model.dart';

abstract class SavedReportsState extends Equatable {
  const SavedReportsState();

  @override
  List<Object?> get props => [];
}

class SavedReportsInitial extends SavedReportsState {
  const SavedReportsInitial();
}

class SavedReportsLoading extends SavedReportsState {
  const SavedReportsLoading();
}

class SavedReportsSuccess extends SavedReportsState {
  final List<SavedReportModel> reports;
  final SavedReportsMeta meta;
  final String selectedFilter;

  const SavedReportsSuccess({
    required this.reports,
    required this.meta,
    required this.selectedFilter,
  });

  @override
  List<Object?> get props => [reports, meta, selectedFilter];
}

class SavedReportsError extends SavedReportsState {
  final String message;

  const SavedReportsError({required this.message});

  @override
  List<Object?> get props => [message];
}

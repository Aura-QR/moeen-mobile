import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/reports/data/models/report_catalogue_model.dart';
import 'package:moean/features/reports/data/repositories/reports_repository.dart';

part 'report_templates_state.dart';

/// The templates to start from, and the teacher's saved reports.
class ReportTemplatesCubit extends Cubit<ReportTemplatesState> {
  static ReportTemplatesCubit get(BuildContext context) => BlocProvider.of(context);

  ReportTemplatesCubit({required ReportsRepository reports, required DocumentsRepository documents})
      : _reports = reports,
        _documents = documents,
        super(const ReportTemplatesState());

  final ReportsRepository _reports;
  final DocumentsRepository _documents;

  Future<void> load() async {
    if (state.catalogue == null) emit(state.copyWith(status: ReportTemplatesStatus.loading));
    final catalogueRequest = _reports.getCatalogue();
    final savedRequest = _documents.getDocuments(type: DocumentTypes.report);
    final catalogue = await catalogueRequest;
    final saved = await savedRequest;
    if (isClosed) return;
    catalogue.fold(
      (failure) => emit(state.copyWith(status: ReportTemplatesStatus.failure, errorMessage: failure.message)),
      (catalogue) => emit(state.copyWith(
        status: ReportTemplatesStatus.success,
        catalogue: catalogue,
        // The list is a shortcut; the templates still work without it.
        saved: saved.fold((_) => state.saved, (page) => page.items),
      )),
    );
  }
}

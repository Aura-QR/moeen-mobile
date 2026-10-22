import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/repositories/ai_jobs_repository.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/repositories/plan_catalogue_repository.dart';
import 'package:moean/features/documents/presentation/cubit/ai_suggestions_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_tool_config.dart';

/// The cubits a plan screen needs, for [tool]. Provided at the route so a
/// pending AI job survives its card scrolling out of view.
class PlanFormProviders extends StatelessWidget {
  final PlanToolConfig tool;

  /// The document to reopen, or null for a new one.
  final int? documentId;
  final Widget child;

  const PlanFormProviders({super.key, required this.tool, required this.documentId, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PlanFormCubit(
            config: tool,
            documentId: documentId,
            catalogueRepository: PlanCatalogueRepository(tool.catalogueUrl),
            documentsRepository: DocumentsRepository(),
            filePicker: DeviceFilePicker(),
          )..load(),
        ),
        BlocProvider(create: (_) => AiSuggestionsCubit(kind: tool.aiKind, repository: AiJobsRepository())),
      ],
      child: child,
    );
  }
}

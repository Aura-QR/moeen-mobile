import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_element_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_element_tile.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

/// «يُحسب شاهدًا لـ» once the map has been saved.
class OutcomesMapElementSection extends StatelessWidget {
  const OutcomesMapElementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OutcomesMapEditorCubit, OutcomesMapEditorState>(
      buildWhen: (previous, current) => previous.documentId != current.documentId,
      builder: (context, state) {
        final documentId = state.documentId;
        if (documentId == null) return const SizedBox.shrink();
        return BlocProvider(
          key: ValueKey(documentId),
          create: (_) => DocumentElementCubit(
            documentId: documentId,
            documents: DocumentsRepository(),
            portfolios: PortfolioRepository(),
          )..load(),
          child: const DocumentElementTile(),
        );
      },
    );
  }
}

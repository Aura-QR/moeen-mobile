import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/performance/presentation/cubit/performance_cubit.dart';
import 'package:moean/features/performance/presentation/widgets/performance_item_documents_section.dart';
import 'package:moean/features/performance/presentation/widgets/performance_item_evidence_section.dart';
import 'package:moean/features/performance/presentation/widgets/performance_item_header.dart';
import 'package:moean/features/performance/presentation/widgets/performance_item_rating_card.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';

/// One element: its rating, its evidence and the documents counted for it.
class PerformanceItemScreen extends StatelessWidget {
  final int itemId;

  const PerformanceItemScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final cubit = PerformanceCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(backgroundColor: ColorsManager.background, elevation: 0),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PerformanceCubit, PerformanceState>(
            listenWhen: (_, current) => current.feedback != null,
            listener: (context, state) =>
                showPrimarySnackBar(context, state.feedback!.message, isError: state.feedback!.isError),
          ),
          // Evidence changed in the editor: the counts and state come from the server.
          BlocListener<PortfolioEditorCubit, PortfolioEditorState>(
            listenWhen: (previous, current) =>
                current.feedback != null || (previous.portfolio != null && previous.portfolio != current.portfolio),
            listener: (context, state) {
              if (state.feedback != null) {
                showPrimarySnackBar(context, state.feedback!.message, isError: state.feedback!.isError);
              }
              cubit.refresh();
            },
          ),
        ],
        child: BlocBuilder<PerformanceCubit, PerformanceState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.performance != current.performance ||
              previous.ratingItemId != current.ratingItemId,
          builder: (context, state) {
            final item = state.performance?.itemById(itemId);
            return ConditionalBuilder(
              loadingState: state.status == PerformanceStatus.loading,
              errorState: state.status == PerformanceStatus.failure || (state.performance != null && item == null),
              emptyState: false,
              errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
              successBuilder: (_) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  PerformanceItemHeader(item: item!),
                  verticalSpace16,
                  if (item.isRatable) ...[
                    PerformanceItemRatingCard(
                      item: item,
                      ratingMax: state.performance!.ratingMax,
                      isSaving: state.ratingItemId == item.id,
                    ),
                    verticalSpace12,
                  ],
                  PerformanceItemEvidenceSection(itemId: itemId),
                  verticalSpace12,
                  PerformanceItemDocumentsSection(item: item),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

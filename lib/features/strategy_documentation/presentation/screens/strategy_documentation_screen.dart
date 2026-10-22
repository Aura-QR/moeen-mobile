import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/documents/presentation/widgets/attach_to_portfolio_sheet.dart';
import 'package:moean/features/documents/presentation/widgets/document_export_sheet.dart';
import 'package:moean/features/strategy_documentation/presentation/cubit/strategy_documentation_cubit.dart';
import 'package:moean/features/strategy_documentation/presentation/widgets/strategy_actions_bar.dart';
import 'package:moean/features/strategy_documentation/presentation/widgets/strategy_documentation_body.dart';

/// T4 «توثيق استراتيجيات التعلم».
class StrategyDocumentationScreen extends StatelessWidget {
  const StrategyDocumentationScreen({super.key});

  Future<void> _onEvent(BuildContext context, StrategyDocumentationState state) async {
    final feedback = state.feedback;
    if (feedback != null) showPrimarySnackBar(context, feedback.message, isError: feedback.isError);

    final documentId = state.documentId;
    if (documentId == null) return;
    switch (state.followUp) {
      case StrategyFollowUp.export:
        await DocumentExportSheet.show(context, documentId: documentId);
      case StrategyFollowUp.attachToPortfolio:
        final attached = await AttachToPortfolioSheet.show(
          context,
          documentId: documentId,
          suggestedItemKey: StrategyDocumentationCubit.portfolioItemKey,
        );
        if (attached && context.mounted) showPrimarySnackBar(context, 'document_attached', isError: false);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('document_type_strategy_documentation'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<StrategyDocumentationCubit, StrategyDocumentationState>(
        listenWhen: (_, current) => current.feedback != null || current.followUp != null,
        listener: _onEvent,
        // Sections rebuild their own parts; this only switches load states.
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == StrategyDocumentationStatus.loading,
          errorState: state.status == StrategyDocumentationStatus.failure,
          errorBuilder: (_) => PrimaryErrorView(
            message: state.errorMessage ?? 'generic_error',
            onRetry: StrategyDocumentationCubit.get(context).load,
          ),
          successBuilder: (_) => const StrategyDocumentationBody(),
        ),
      ),
      bottomNavigationBar: const StrategyActionsBar(),
    );
  }
}

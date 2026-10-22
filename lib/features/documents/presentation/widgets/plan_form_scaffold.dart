import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';
import 'package:moean/features/documents/presentation/cubit/ai_suggestions_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_tool_config.dart';
import 'package:moean/features/documents/presentation/widgets/attach_to_portfolio_sheet.dart';
import 'package:moean/features/documents/presentation/widgets/document_export_sheet.dart';
import 'package:moean/features/documents/presentation/widgets/plan_actions_bar.dart';

/// The screen around a plan form: load states, messages, the export and
/// portfolio sheets after a save, and AI suggestions joining the sections.
/// Needs a [PlanFormCubit] and an [AiSuggestionsCubit] above it.
class PlanFormScaffold extends StatelessWidget {
  final String titleKey;
  final Widget body;

  const PlanFormScaffold({super.key, required this.titleKey, required this.body});

  Future<void> _onPlanEvent(BuildContext context, PlanFormState state) async {
    final feedback = state.feedback;
    if (feedback != null) showPrimarySnackBar(context, feedback.message, isError: feedback.isError);

    final documentId = state.documentId;
    if (documentId == null) return;
    switch (state.followUp) {
      case PlanFollowUp.export:
        await DocumentExportSheet.show(context, documentId: documentId);
      case PlanFollowUp.attachToPortfolio:
        final attached = await AttachToPortfolioSheet.show(
          context,
          documentId: documentId,
          suggestedItemKey: PlanToolConfig.portfolioItemKey,
        );
        if (attached && context.mounted) showPrimarySnackBar(context, 'document_attached', isError: false);
      case null:
        break;
    }
  }

  void _onAiEvent(BuildContext context, AiSuggestionsState state) {
    final payment = state.paymentRequired;
    if (payment != null) {
      UpgradePromptBottomSheet.show(
        context,
        message: payment.message,
        isQuotaExceeded: payment.code == 'quota_exceeded',
      );
      return;
    }
    PlanFormCubit.get(context).addSuggestions(state.result);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get(titleKey),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocListener<AiSuggestionsCubit, AiSuggestionsState>(
        listenWhen: (previous, current) =>
            (current.status == AiSuggestionsStatus.done && previous.status != AiSuggestionsStatus.done) ||
            (current.paymentRequired != null && previous.paymentRequired != current.paymentRequired),
        listener: _onAiEvent,
        child: BlocConsumer<PlanFormCubit, PlanFormState>(
          listenWhen: (_, current) => current.feedback != null || current.followUp != null,
          listener: _onPlanEvent,
          // Sections rebuild their own parts; this only switches load states.
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) => ConditionalBuilder(
            loadingState: state.status == PlanFormStatus.loading,
            errorState: state.status == PlanFormStatus.failure,
            errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
            successBuilder: (_) => body,
          ),
        ),
      ),
      bottomNavigationBar: const PlanActionsBar(),
    );
  }
}

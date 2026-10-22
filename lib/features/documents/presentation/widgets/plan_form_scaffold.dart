import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/plan_tool_config.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/documents/presentation/widgets/document_ai_listener.dart';
import 'package:moean/features/documents/presentation/widgets/plan_actions_bar.dart';

/// The screen around a plan form: load states, messages, the export and
/// portfolio sheets after a save, and AI suggestions joining the sections.
/// Needs a [PlanFormCubit] and an AiSuggestionsCubit above it.
class PlanFormScaffold extends StatelessWidget {
  final String titleKey;
  final Widget body;

  const PlanFormScaffold({super.key, required this.titleKey, required this.body});

  Future<void> _onPlanEvent(BuildContext context, PlanFormState state) async {
    final feedback = state.feedback;
    if (feedback != null) showPrimarySnackBar(context, feedback.message, isError: feedback.isError);

    final documentId = state.documentId;
    if (documentId == null) return;
    await runDocumentFollowUp(
      context,
      followUp: state.followUp,
      documentId: documentId,
      documentType: PlanFormCubit.get(context).config.documentType,
      portfolioItemKey: PlanToolConfig.portfolioItemKey,
    );
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
      body: DocumentAiListener(
        onResult: cubit.addSuggestions,
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

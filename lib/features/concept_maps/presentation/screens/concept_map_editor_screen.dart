import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_map_editor_cubit.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_actions_bar.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_editor_body.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_preview_sheet.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_node_sheet.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';

/// L9 «خرائط المفاهيم» editor screen. Saves quietly when leaving with valid changes.
class ConceptMapEditorScreen extends StatelessWidget {
  const ConceptMapEditorScreen({super.key});

  Future<void> _onEvent(
    BuildContext context,
    ConceptMapEditorState state,
  ) async {
    final payment = state.paymentRequired;
    if (payment != null) {
      UpgradePromptBottomSheet.show(
        context,
        message: payment.message,
        isQuotaExceeded: payment.code == 'quota_exceeded',
      );
      return;
    }

    final feedback = state.feedback;
    if (feedback != null) {
      showPrimarySnackBar(context, feedback.message, isError: feedback.isError);
    }

    final openNodeId = state.openNodeSheetId;
    if (openNodeId != null && context.mounted) {
      await ConceptNodeSheet.show(
        context,
        cubit: ConceptMapEditorCubit.get(context),
        nodeId: openNodeId,
      );
    }

    final documentId = state.documentId;
    if (documentId == null || !context.mounted) return;
    await runDocumentFollowUp(
      context,
      followUp: state.followUp,
      documentId: documentId,
      documentType: DocumentTypes.conceptMap,
      portfolioItemKey: ConceptMapEditorCubit.portfolioItemKey,
    );
  }

  Future<void> _onPop(BuildContext context, bool didPop) async {
    if (didPop) return;
    await ConceptMapEditorCubit.get(context).saveIfDirty();
    if (context.mounted) AppRouter.pop(null, context);
  }

  void _openPreview(BuildContext context) {
    final cubit = ConceptMapEditorCubit.get(context);
    ConceptMapPreviewSheet.show(
      context,
      input: cubit.buildPreviewPayload(),
      title: cubit.titleController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ConceptMapEditorCubit.get(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPop(context, didPop),
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            appTranslation().get('concept_maps_title'),
            style: TextStylesManager.bold16.copyWith(
              color: ColorsManager.mainText,
            ),
          ),
          actions: [
            BlocBuilder<ConceptMapEditorCubit, ConceptMapEditorState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status,
              builder: (context, state) => TextButton.icon(
                onPressed: state.status == ConceptMapEditorStatus.success
                    ? () => _openPreview(context)
                    : null,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text(appTranslation().get('concept_map_preview')),
              ),
            ),
          ],
        ),
        body: BlocConsumer<ConceptMapEditorCubit, ConceptMapEditorState>(
          listenWhen: (_, current) =>
              current.feedback != null ||
              current.followUp != null ||
              current.paymentRequired != null ||
              current.openNodeSheetId != null,
          listener: _onEvent,
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) => ConditionalBuilder(
            loadingState: state.status == ConceptMapEditorStatus.loading,
            errorState: state.status == ConceptMapEditorStatus.failure,
            errorBuilder: (_) => PrimaryErrorView(
              message: state.errorMessage ?? 'generic_error',
              onRetry: cubit.load,
            ),
            successBuilder: (_) => const ConceptMapEditorBody(),
          ),
        ),
        bottomNavigationBar: const ConceptMapActionsBar(),
      ),
    );
  }
}

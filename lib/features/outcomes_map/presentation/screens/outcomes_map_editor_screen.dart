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
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_actions_bar.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_editor_body.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_lesson_sheet.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_preview_sheet.dart';

/// L9 «خريطة نواتج التعلم» editor screen. Saves quietly when leaving with valid changes.
class OutcomesMapEditorScreen extends StatelessWidget {
  const OutcomesMapEditorScreen({super.key});

  Future<void> _onEvent(BuildContext context, OutcomesMapEditorState state) async {
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

    final openLesson = state.openLesson;
    if (openLesson != null && context.mounted) {
      await OutcomesMapLessonSheet.show(
        context,
        cubit: OutcomesMapEditorCubit.get(context),
        ref: openLesson,
      );
    }

    final documentId = state.documentId;
    if (documentId == null || !context.mounted) return;
    await runDocumentFollowUp(
      context,
      followUp: state.followUp,
      documentId: documentId,
      documentType: DocumentTypes.outcomesMap,
      portfolioItemKey: OutcomesMapEditorCubit.portfolioItemKey,
    );
  }

  Future<void> _onPop(BuildContext context, bool didPop) async {
    if (didPop) return;
    await OutcomesMapEditorCubit.get(context).saveIfDirty();
    if (context.mounted) AppRouter.pop(null, context);
  }

  void _openPreview(BuildContext context) {
    final cubit = OutcomesMapEditorCubit.get(context);
    OutcomesMapPreviewSheet.show(
      context,
      input: cubit.buildPreviewPayload(),
      title: cubit.titleController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = OutcomesMapEditorCubit.get(context);
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
            appTranslation().get('outcomes_map_title'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
          actions: [
            BlocBuilder<OutcomesMapEditorCubit, OutcomesMapEditorState>(
              buildWhen: (previous, current) => previous.status != current.status,
              builder: (context, state) => TextButton.icon(
                onPressed: state.status == OutcomesMapEditorStatus.success
                    ? () => _openPreview(context)
                    : null,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text(appTranslation().get('outcomes_map_preview')),
              ),
            ),
          ],
        ),
        body: BlocConsumer<OutcomesMapEditorCubit, OutcomesMapEditorState>(
          listenWhen: (_, current) =>
              current.feedback != null ||
              current.followUp != null ||
              current.paymentRequired != null ||
              current.openLesson != null,
          listener: _onEvent,
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) => ConditionalBuilder(
            loadingState: state.status == OutcomesMapEditorStatus.loading,
            errorState: state.status == OutcomesMapEditorStatus.failure,
            errorBuilder: (_) => PrimaryErrorView(
              message: state.errorMessage ?? 'generic_error',
              onRetry: cubit.load,
            ),
            successBuilder: (_) => const OutcomesMapEditorBody(),
          ),
        ),
        bottomNavigationBar: const OutcomesMapActionsBar(),
      ),
    );
  }
}

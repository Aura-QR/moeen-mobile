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
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/reading_editor_cubit.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_actions_bar.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_editor_body.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_preview_sheet.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_question_sheet.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_settings_sheet.dart';

/// L12 «الفهم القرائي» editor: three tabs (القطعة، المفردات، الأسئلة), preview,
/// save/export and «شارك إلكترونيًا». Saves quietly when leaving with changes.
class ReadingEditorScreen extends StatelessWidget {
  const ReadingEditorScreen({super.key});

  Future<void> _onEvent(BuildContext context, ReadingEditorState state) async {
    final cubit = ReadingEditorCubit.get(context);
    final payment = state.paymentRequired;
    if (payment != null) {
      UpgradePromptBottomSheet.show(context, message: payment.message, isQuotaExceeded: payment.code == 'quota_exceeded');
      return;
    }
    if (state.feedback != null) {
      showPrimarySnackBar(context, state.feedback!.message, isError: state.feedback!.isError);
    }

    final openIndex = state.openQuestionIndex;
    if (openIndex != null && context.mounted) {
      await ReadingQuestionSheet.show(context, cubit: cubit, index: openIndex);
      if (context.mounted) cubit.consumeOpenQuestion();
    }

    final exam = state.shareExamRef;
    if (exam != null && exam.examId > 0 && context.mounted) {
      await AppRouter.push(
        Routes.createOnlineTest,
        arguments: {'exam_id': exam.examId, 'title': exam.title},
        context: context,
      );
    }

    final documentId = state.documentId;
    if (state.followUp != null && documentId != null && context.mounted) {
      await runDocumentFollowUp(
        context,
        followUp: state.followUp,
        documentId: documentId,
        documentType: DocumentTypes.readingComprehension,
        portfolioItemKey: ReadingEditorCubit.portfolioItemKey,
      );
    }
  }

  Future<void> _onPop(BuildContext context, bool didPop) async {
    if (didPop) return;
    await ReadingEditorCubit.get(context).saveIfDirty();
    if (context.mounted) AppRouter.pop(null, context);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReadingEditorCubit.get(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPop(context, didPop),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              appTranslation().get('reading_title'),
              style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
            ),
            actions: [
              IconButton(
                tooltip: appTranslation().get('reading_settings_title'),
                onPressed: () => ReadingSettingsSheet.show(context, cubit: cubit),
                icon: const Icon(Icons.tune_rounded, size: 20),
              ),
              IconButton(
                tooltip: appTranslation().get('reading_preview'),
                onPressed: () => ReadingPreviewSheet.show(
                  context,
                  input: cubit.buildPreviewPayload(),
                  title: cubit.titleController.text,
                ),
                icon: const Icon(Icons.visibility_outlined, size: 20),
              ),
            ],
            bottom: TabBar(
              labelColor: ColorsManager.primaryColor,
              unselectedLabelColor: ColorsManager.secondaryText,
              indicatorColor: ColorsManager.primaryColor,
              tabs: [
                Tab(text: appTranslation().get('reading_tab_passage')),
                Tab(text: appTranslation().get('reading_tab_vocabulary')),
                Tab(text: appTranslation().get('reading_tab_questions')),
              ],
            ),
          ),
          body: BlocConsumer<ReadingEditorCubit, ReadingEditorState>(
            listenWhen: (_, c) =>
                c.feedback != null ||
                c.followUp != null ||
                c.paymentRequired != null ||
                c.openQuestionIndex != null ||
                c.shareExamRef != null,
            listener: _onEvent,
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, state) => ConditionalBuilder(
              loadingState: state.status == ReadingEditorStatus.loading,
              errorState: state.status == ReadingEditorStatus.failure,
              errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
              successBuilder: (_) => const ReadingEditorBody(),
            ),
          ),
          bottomNavigationBar: const ReadingActionsBar(),
        ),
      ),
    );
  }
}

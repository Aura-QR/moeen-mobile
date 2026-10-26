import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_actions_bar.dart';
import 'package:moean/features/reports/presentation/widgets/report_editor_body.dart';

/// T8 «التقارير والشواهد» & L1 «حقائب الأدوار» report editor.
/// Needs a [ReportEditorCubit] above it. Leaving saves quietly when something changed.
class ReportEditorScreen extends StatelessWidget {
  const ReportEditorScreen({super.key});

  Future<void> _onEvent(BuildContext context, ReportEditorState state) async {
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
    if (feedback != null) showPrimarySnackBar(context, feedback.message, isError: feedback.isError);
    final documentId = state.documentId;
    if (documentId == null) return;
    await runDocumentFollowUp(
      context,
      followUp: state.followUp,
      documentId: documentId,
      documentType: DocumentTypes.report,
      portfolioItemKey: ReportEditorCubit.get(context).activePortfolioItemKey,
    );
  }

  Future<void> _onPop(BuildContext context, bool didPop) async {
    if (didPop) return;
    final navigator = Navigator.of(context);
    await ReportEditorCubit.get(context).saveIfDirty();
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
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
            appTranslation().get(DocumentTypes.labelKey(DocumentTypes.report)),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          ),
        ),
        body: BlocConsumer<ReportEditorCubit, ReportEditorState>(
          listenWhen: (_, current) =>
              current.feedback != null ||
              current.followUp != null ||
              current.paymentRequired != null,
          listener: _onEvent,
          // Sections rebuild their own parts; this only switches load states.
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) => ConditionalBuilder(
            loadingState: state.status == ReportEditorStatus.loading,
            errorState: state.status == ReportEditorStatus.failure,
            errorBuilder: (_) => PrimaryErrorView(
              message: state.errorMessage ?? 'generic_error',
              onRetry: cubit.load,
            ),
            successBuilder: (_) => const ReportEditorBody(),
          ),
        ),
        bottomNavigationBar: const ReportActionsBar(),
      ),
    );
  }
}

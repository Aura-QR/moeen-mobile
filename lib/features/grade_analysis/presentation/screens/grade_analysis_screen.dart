import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/documents/presentation/widgets/document_ai_listener.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_results_cubit.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_analysis_actions_bar.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_analysis_body.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_delete_all_button.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_import_review_sheet.dart';

/// T7 «تحليل نتائج الطلاب». Needs a [GradeAnalysisCubit], a [GradeResultsCubit]
/// and an AiSuggestionsCubit above it.
class GradeAnalysisScreen extends StatelessWidget {
  const GradeAnalysisScreen({super.key});

  Future<void> _onEvent(BuildContext context, GradeAnalysisState state) async {
    final cubit = GradeAnalysisCubit.get(context);
    final feedback = state.feedback;
    if (feedback != null) showPrimarySnackBar(context, feedback.message, isError: feedback.isError);

    final sheet = state.importedSheet;
    if (sheet != null) {
      if (await GradeImportReviewSheet.show(context, sheet)) cubit.applyImport(sheet);
      return;
    }

    final documentId = state.documentId;
    if (documentId == null || !context.mounted) return;
    await runDocumentFollowUp(
      context,
      followUp: state.followUp,
      documentId: documentId,
      documentType: DocumentTypes.gradeAnalysis,
      portfolioItemKey: GradeAnalysisCubit.portfolioItemKey,
    );
  }

  /// Re-analyses after each change, or says what the form still needs.
  void _refreshResults(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    final results = GradeResultsCubit.get(context);
    final issue = cubit.analysisIssue;
    if (issue != null) {
      results.wait(issue);
      return;
    }
    results.schedule(cubit.analysisInput()!);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get(DocumentTypes.labelKey(DocumentTypes.gradeAnalysis)),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
        actions: const [GradeDeleteAllButton()],
      ),
      body: DocumentAiListener(
        onResult: (result) => cubit.addSuggestions(result['recommendations'] ?? const []),
        child: BlocListener<GradeAnalysisCubit, GradeAnalysisState>(
          listenWhen: (previous, current) => previous.revision != current.revision,
          listener: (context, _) => _refreshResults(context),
          child: BlocConsumer<GradeAnalysisCubit, GradeAnalysisState>(
            listenWhen: (_, current) =>
                current.feedback != null || current.followUp != null || current.importedSheet != null,
            listener: _onEvent,
            // Sections rebuild their own parts; this only switches load states.
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) => ConditionalBuilder(
              loadingState: state.status == GradeAnalysisStatus.loading,
              errorState: state.status == GradeAnalysisStatus.failure,
              errorBuilder: (_) =>
                  PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
              successBuilder: (_) => const GradeAnalysisBody(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const GradeAnalysisActionsBar(),
    );
  }
}

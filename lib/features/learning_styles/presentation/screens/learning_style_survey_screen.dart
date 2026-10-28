import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/features/documents/presentation/widgets/document_export_sheet.dart';
import 'package:moean/features/learning_styles/data/repositories/learning_styles_repository.dart';
import 'package:moean/features/learning_styles/presentation/cubit/learning_style_survey_cubit.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_results_tab.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_share_tab.dart';

/// One survey: «المشاركة» (links and QR) and «النتائج» (mix, students, report).
class LearningStyleSurveyScreen extends StatelessWidget {
  const LearningStyleSurveyScreen({super.key});

  static Widget create(int id) => BlocProvider(
        create: (_) => LearningStyleSurveyCubit(surveyId: id, repository: LearningStylesRepository())..load(),
        child: const LearningStyleSurveyScreen(),
      );

  Future<void> _listen(BuildContext context, LearningStyleSurveyState state) async {
    final cubit = LearningStyleSurveyCubit.get(context);
    if (state.message != null) {
      showPrimarySnackBar(context, appTranslation().get(state.message!), isError: state.messageIsError);
      cubit.clearMessage();
    }
    if (state.deleted) {
      Navigator.pop(context);
      return;
    }
    final reportId = state.reportDocumentId;
    if (reportId != null) {
      cubit.clearReport();
      await DocumentExportSheet.show(context, documentId: reportId, noteKey: 'learning_styles_report_note');
    }
  }

  Future<void> _menu(BuildContext context, String action) async {
    final cubit = LearningStyleSurveyCubit.get(context);
    if (action == 'toggle') {
      await cubit.toggleOpen();
    } else if (action == 'delete') {
      final ok = await showPrimaryConfirmDialog(
        context,
        titleKey: 'learning_styles_delete_title',
        messageKey: 'learning_styles_delete_message',
      );
      if (ok) await cubit.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = LearningStyleSurveyCubit.get(context);
    return BlocConsumer<LearningStyleSurveyCubit, LearningStyleSurveyState>(
      listenWhen: (a, b) =>
          a.message != b.message || a.deleted != b.deleted || a.reportDocumentId != b.reportDocumentId,
      listener: _listen,
      builder: (context, state) {
        final survey = state.survey;
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: AppBar(
              backgroundColor: ColorsManager.background,
              elevation: 0,
              centerTitle: true,
              title: Text(survey?.title ?? appTranslation().get('learning_styles_title'),
                  style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText), overflow: TextOverflow.ellipsis),
              actions: [
                if (survey != null)
                  PopupMenuButton<String>(
                    onSelected: (v) => _menu(context, v),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(appTranslation().get(survey.isOpen ? 'learning_styles_close' : 'learning_styles_reopen')),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(appTranslation().get('delete'), style: const TextStyle(color: ColorsManager.errorColor)),
                      ),
                    ],
                  ),
              ],
              bottom: survey == null
                  ? null
                  : TabBar(
                      labelColor: ColorsManager.primaryColor,
                      unselectedLabelColor: ColorsManager.secondaryText,
                      indicatorColor: ColorsManager.primaryColor,
                      tabs: [
                        Tab(text: appTranslation().get('learning_styles_share')),
                        Tab(text: '${appTranslation().get('learning_styles_results')} (${survey.responses})'),
                      ],
                    ),
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : survey == null
                    ? PrimaryErrorView(message: state.loadError ?? 'generic_error', onRetry: cubit.load)
                    : const TabBarView(children: [LearningStyleShareTab(), LearningStyleResultsTab()]),
          ),
        );
      },
    );
  }
}

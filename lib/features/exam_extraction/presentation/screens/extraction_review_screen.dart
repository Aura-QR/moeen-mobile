import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_state.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_missing_answers_banner.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_question_card.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_save_bar.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_source_content_banner.dart';

class ExtractionReviewScreen extends StatelessWidget {
  const ExtractionReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final cubit = ExtractionReviewCubit.get(context);
        if (cubit.state.questions.isEmpty || cubit.state.saved) {
          Navigator.pop(context);
          return;
        }
        final confirm = await showPrimaryConfirmDialog(
          context,
          titleKey: 'warning',
          messageKey: 'exam_extract_leave_confirm',
        );
        if (confirm && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
          title: Text(
            appTranslation().get('exam_extract_title'),
            style: TextStylesManager.bold16.copyWith(
              color: ColorsManager.mainText,
            ),
          ),
          backgroundColor: ColorsManager.background,
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocConsumer<ExtractionReviewCubit, ExtractionReviewState>(
            listenWhen: (previous, current) =>
                previous.saved != current.saved ||
                previous.paymentRequired != current.paymentRequired ||
                (current.error != null && previous.error != current.error),
            listener: (context, state) {
              if (state.saved) {
                showPrimarySnackBar(
                  context,
                  'exam_extract_saved',
                  isError: false,
                );
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.myExams,
                  (route) =>
                      route.settings.name == Routes.home || route.isFirst,
                );
                return;
              }

              if (state.paymentRequired) {
                UpgradePromptBottomSheet.show(
                  context,
                  message:
                      appTranslation().get(state.error ?? 'quota_exceeded'),
                  isQuotaExceeded: true,
                );
                return;
              }

              if (state.error != null) {
                showPrimarySnackBar(context, state.error!, isError: true);
                ExtractionReviewCubit.get(context).clearError();
              }
            },
            buildWhen: (previous, current) =>
                previous.questions.length != current.questions.length ||
                previous.source != current.source ||
                previous.missingCount != current.missingCount,
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  if (state.source == 'content') ...[
                    const ExtractionSourceContentBanner(),
                    verticalSpace12,
                  ],
                  if (state.missingCount > 0) ...[
                    ExtractionMissingAnswersBanner(count: state.missingCount),
                    verticalSpace12,
                  ],
                  for (int i = 0; i < state.questions.length; i++)
                    ExtractionQuestionCard(key: ValueKey(i), index: i),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: const ExtractionSaveBar(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_job_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_job_state.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_progress_view.dart';
import 'package:moean/features/exam_extraction/presentation/widgets/extraction_reading_error_view.dart';

class ExtractionReadingScreen extends StatelessWidget {
  const ExtractionReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: BlocConsumer<ExtractionJobCubit, ExtractionJobState>(
          listenWhen: (previous, current) =>
              previous.status != current.status ||
              previous.paymentRequired != current.paymentRequired,
          listener: (context, state) {
            if (state.paymentRequired) {
              UpgradePromptBottomSheet.show(
                context,
                message: appTranslation().get(state.error ?? 'quota_exceeded'),
                isQuotaExceeded: true,
              ).then((_) {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              });
              return;
            }

            if (state.status == ExtractionJobStatus.done && state.job != null) {
              Navigator.pushReplacementNamed(
                context,
                Routes.examExtractionReview,
                arguments: state.job,
              );
            }
          },
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) {
            if (state.status == ExtractionJobStatus.failed ||
                state.status == ExtractionJobStatus.timedOut) {
              return ExtractionReadingErrorView(
                error: state.error ?? 'exam_extract_timeout',
              );
            }
            return const ExtractionProgressView();
          },
        ),
      ),
    );
  }
}

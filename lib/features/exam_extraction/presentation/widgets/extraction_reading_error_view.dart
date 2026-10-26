import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_job_cubit.dart';

class ExtractionReadingErrorView extends StatelessWidget {
  final String error;

  const ExtractionReadingErrorView({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PrimaryErrorView(
          message: error,
          onRetry: () => ExtractionJobCubit.get(context).retry(),
        ),
        verticalSpace12,
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            appTranslation().get('exam_extract_change_pages'),
            style: TextStylesManager.medium14.copyWith(
              color: ColorsManager.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_job_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_job_state.dart';

class ExtractionProgressView extends StatelessWidget {
  const ExtractionProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExtractionJobCubit, ExtractionJobState>(
      buildWhen: (previous, current) =>
          previous.elapsedSeconds != current.elapsedSeconds ||
          previous.progressMessageKey != current.progressMessageKey,
      builder: (context, state) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorsManager.primaryColor,
                    ),
                  ),
                ),
                verticalSpace24,
                Text(
                  appTranslation().get(state.progressMessageKey),
                  textAlign: TextAlign.center,
                  style: TextStylesManager.bold16.copyWith(
                    color: ColorsManager.mainText,
                  ),
                ),
                verticalSpace8,
                Text(
                  '${state.elapsedSeconds}s',
                  style: TextStylesManager.regular13.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

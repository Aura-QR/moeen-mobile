import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/diagnostic_test/presentation/cubit/diagnostic_create_cubit.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/diagnostic_curriculum_card.dart';
import 'package:moean/features/diagnostic_test/presentation/widgets/diagnostic_size_card.dart';

class DiagnosticPickView extends StatelessWidget {
  final DiagnosticCreateState state;

  const DiagnosticPickView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = DiagnosticCreateCubit.get(context);
    final writing = state.step == DiagnosticStep.writing;

    return ConditionalBuilder(
      loadingState: state.isStagesLoading,
      errorState: state.stagesError != null,
      emptyState: state.stages.isEmpty,
      errorBuilder: (_) => PrimaryErrorView(
        message: state.stagesError!,
        onRetry: cubit.loadStages,
      ),
      emptyBuilder: (_) => PrimaryErrorView(
        message: 'generic_error',
        onRetry: cubit.loadStages,
      ),
      successBuilder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            appTranslation().get('diagnostic_intro'),
            style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
          ),
          verticalSpace12,
          DiagnosticCurriculumCard(state: state),
          verticalSpace12,
          DiagnosticSizeCard(state: state),
          verticalSpace16,
          PrimaryElevatedButton(
            text: appTranslation().get(writing ? 'diagnostic_writing' : 'diagnostic_generate'),
            isLoading: writing,
            onPressed: state.canGenerate ? () => cubit.generate() : null,
          ),
          verticalSpace16,
        ],
      ),
    );
  }
}

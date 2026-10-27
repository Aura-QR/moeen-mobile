import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_bottom_sheet.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_editor_args.dart';
import 'package:moean/features/concept_maps/presentation/cubit/new_concept_map_cubit.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_curriculum_card.dart';
import 'package:moean/features/concept_maps/presentation/widgets/new_concept_map_actions_section.dart';

/// Dedicated screen for «خريطة جديدة»: Stage → Grade → Subject → Lesson dropdowns + AI or blank start.
class NewConceptMapScreen extends StatelessWidget {
  const NewConceptMapScreen({super.key});

  void _onEvent(BuildContext context, NewConceptMapState state) {
    final payment = state.paymentRequired;
    if (payment != null) {
      UpgradePromptBottomSheet.show(
        context,
        message: payment.message,
        isQuotaExceeded: payment.code == 'quota_exceeded',
      );
      return;
    }
    final generated = state.generatedInput;
    if (generated != null) {
      AppRouter.pop(ConceptMapEditorArgs(initialInput: generated), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = NewConceptMapCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('concept_map_new'),
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
      ),
      body: BlocConsumer<NewConceptMapCubit, NewConceptMapState>(
        listenWhen: (_, current) =>
            current.generatedInput != null || current.paymentRequired != null,
        listener: _onEvent,
        buildWhen: (previous, current) =>
            previous.isStagesLoading != current.isStagesLoading ||
            previous.stagesError != current.stagesError ||
            previous.stages != current.stages ||
            previous.selectedStage != current.selectedStage ||
            previous.selectedTrack != current.selectedTrack ||
            previous.selectedGrade != current.selectedGrade ||
            previous.selectedSubject != current.selectedSubject ||
            previous.isLessonsLoading != current.isLessonsLoading ||
            previous.chapters != current.chapters ||
            previous.selectedLesson != current.selectedLesson ||
            previous.aiStatus != current.aiStatus ||
            previous.aiErrorMessage != current.aiErrorMessage,
        builder: (context, state) => ConditionalBuilder(
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                appTranslation().get('concept_map_new_subtitle'),
                style: TextStylesManager.regular13.copyWith(
                  color: ColorsManager.secondaryText,
                ),
              ),
              verticalSpace12,
              ConceptMapCurriculumCard(state: state),
              verticalSpace16,
              NewConceptMapActionsSection(
                state: state,
                onStartBlank: () =>
                    AppRouter.pop(const ConceptMapEditorArgs(), context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

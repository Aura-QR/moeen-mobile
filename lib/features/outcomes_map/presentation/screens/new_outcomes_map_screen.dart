import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_editor_args.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/new_outcomes_map_cubit.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/new_outcomes_map_actions_section.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_curriculum_card.dart';

/// «خريطة جديدة»: Stage → Grade → Subject → Semester, then «ابدأ» opens the editor.
class NewOutcomesMapScreen extends StatelessWidget {
  const NewOutcomesMapScreen({super.key});

  void _onEvent(BuildContext context, NewOutcomesMapState state) {
    final generated = state.generatedInput;
    if (generated != null) {
      AppRouter.pop(OutcomesMapEditorArgs(initialInput: generated), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = NewOutcomesMapCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('outcomes_map_new'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<NewOutcomesMapCubit, NewOutcomesMapState>(
        listenWhen: (_, current) => current.generatedInput != null,
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
            previous.semester != current.semester,
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
                appTranslation().get('outcomes_map_new_subtitle'),
                style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace12,
              OutcomesMapCurriculumCard(state: state),
              verticalSpace16,
              NewOutcomesMapActionsSection(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

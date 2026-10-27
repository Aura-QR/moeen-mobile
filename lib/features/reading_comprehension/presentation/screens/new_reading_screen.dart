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
import 'package:moean/features/reading_comprehension/data/models/reading_editor_args.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/new_reading_cubit.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_curriculum_card.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/reading_options_section.dart';
import 'package:moean/features/reading_comprehension/presentation/widgets/new_reading_actions_section.dart';

/// «قطعة جديدة»: pick a lesson, set the options, then «✨ اكتب القطعة والأسئلة».
class NewReadingScreen extends StatelessWidget {
  const NewReadingScreen({super.key});

  void _onEvent(BuildContext context, NewReadingState state) {
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
      AppRouter.pop(ReadingEditorArgs(initialInput: generated), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = NewReadingCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('reading_new'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<NewReadingCubit, NewReadingState>(
        listenWhen: (_, current) => current.generatedInput != null || current.paymentRequired != null,
        listener: _onEvent,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.isStagesLoading,
          errorState: state.stagesError != null,
          emptyState: state.stages.isEmpty,
          errorBuilder: (_) => PrimaryErrorView(message: state.stagesError!, onRetry: cubit.loadStages),
          emptyBuilder: (_) => PrimaryErrorView(message: 'generic_error', onRetry: cubit.loadStages),
          successBuilder: (_) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                appTranslation().get('reading_new_subtitle'),
                style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace12,
              ReadingCurriculumCard(state: state),
              verticalSpace16,
              ReadingOptionsSection(state: state),
              verticalSpace16,
              NewReadingActionsSection(
                state: state,
                onStartBlank: () => AppRouter.pop(const ReadingEditorArgs(), context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

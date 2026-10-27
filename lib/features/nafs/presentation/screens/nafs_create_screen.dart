import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/exam_generation/domain/usecases/get_exam_usecase.dart';
import 'package:moean/features/nafs/data/repositories/nafs_repository.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_choose_view.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_generating_view.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_review_view.dart';

class NafsCreateScreen extends StatelessWidget {
  const NafsCreateScreen({super.key});

  static Widget create() => BlocProvider(
        create: (_) => NafsCubit(NafsRepository())..loadOptions(),
        child: const NafsCreateScreen(),
      );

  Future<void> _handleSavedExam(BuildContext context, int examId) async {
    showPrimarySnackBar(context, appTranslation().get('nafs_saved'), isError: false);
    final result = await sl<GetExamUseCase>().execute(examId);
    if (!context.mounted) return;
    result.fold(
      (_) => Navigator.pop(context, true),
      (exam) => Navigator.pushReplacementNamed(
        context,
        Routes.examGenerationPreview,
        arguments: exam,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = NafsCubit.get(context);

    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('nafs_entry_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<NafsCubit, NafsState>(
        listenWhen: (prev, curr) =>
            prev.error != curr.error || prev.savedExamId != curr.savedExamId,
        buildWhen: (prev, curr) =>
            prev.step != curr.step ||
            prev.isLoadingOptions != curr.isLoadingOptions ||
            prev.optionsError != curr.optionsError ||
            prev.grades != curr.grades ||
            prev.selectedGrade != curr.selectedGrade ||
            prev.selectedSubject != curr.selectedSubject ||
            prev.selectedDomainIds != curr.selectedDomainIds ||
            prev.questionsCount != curr.questionsCount ||
            prev.isRealExam != curr.isRealExam ||
            prev.passage != curr.passage ||
            prev.domains != curr.domains ||
            prev.title != curr.title ||
            prev.isSaving != curr.isSaving,
        listener: (context, state) {
          if (state.error != null) {
            showPrimarySnackBar(context, appTranslation().get(state.error!), isError: true);
            cubit.clearError();
          }
          if (state.savedExamId != null) {
            _handleSavedExam(context, state.savedExamId!);
          }
        },
        builder: (context, state) {
          return ConditionalBuilder(
            loadingState: state.isLoadingOptions,
            errorState: state.optionsError != null && state.grades.isEmpty,
            errorBuilder: (_) => PrimaryErrorView(
              message: state.optionsError!,
              onRetry: cubit.loadOptions,
            ),
            successBuilder: (_) {
              if (state.step == NafsStep.generating) {
                return const NafsGeneratingView();
              }
              if (state.step == NafsStep.review) {
                return NafsReviewView(state: state);
              }
              return NafsChooseView(state: state);
            },
          );
        },
      ),
    );
  }
}

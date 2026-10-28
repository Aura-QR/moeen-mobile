import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/exam_generation/domain/usecases/get_exam_usecase.dart';
import 'package:moean/features/tahsili/data/repositories/tahsili_repository.dart';
import 'package:moean/features/tahsili/presentation/cubit/tahsili_cubit.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_choose_view.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_generating_view.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_review_view.dart';

class TahsiliTabView extends StatelessWidget {
  const TahsiliTabView({super.key});

  static Widget create() => BlocProvider(
        create: (_) => TahsiliCubit(TahsiliRepository())..loadOptions(),
        child: const TahsiliTabView(),
      );

  Future<void> _handleSavedExam(BuildContext context, int examId) async {
    showPrimarySnackBar(context, appTranslation().get('tahsili_saved'), isError: false);
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
    final cubit = TahsiliCubit.get(context);

    return Scaffold(
      backgroundColor: ColorsManager.background,
      body: BlocConsumer<TahsiliCubit, TahsiliState>(
        listenWhen: (prev, curr) =>
            prev.error != curr.error || prev.savedExamId != curr.savedExamId,
        buildWhen: (prev, curr) =>
            prev.step != curr.step ||
            prev.isLoadingOptions != curr.isLoadingOptions ||
            prev.optionsError != curr.optionsError ||
            prev.options != curr.options ||
            prev.selectedSubject != curr.selectedSubject ||
            prev.selectedDomainIds != curr.selectedDomainIds ||
            prev.questionsCount != curr.questionsCount ||
            prev.domains != curr.domains ||
            prev.title != curr.title ||
            prev.isSaving != curr.isSaving ||
            prev.fieldErrors != curr.fieldErrors,
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
            errorState: state.optionsError != null && state.options.subjects.isEmpty,
            errorBuilder: (_) => PrimaryErrorView(
              message: state.optionsError!,
              onRetry: cubit.loadOptions,
            ),
            successBuilder: (_) {
              if (state.step == TahsiliStep.generating) {
                return const TahsiliGeneratingView();
              }
              if (state.step == TahsiliStep.review) {
                return TahsiliReviewView(state: state);
              }
              return TahsiliChooseView(state: state);
            },
          );
        },
      ),
    );
  }
}

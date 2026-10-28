import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_state.dart';
import 'package:moean/features/exam_generation/presentation/widgets/my_exams_header_widget.dart';
import 'package:moean/features/exam_generation/presentation/widgets/my_exams_list_view.dart';

class MyExamsScreen extends StatelessWidget {
  const MyExamsScreen({super.key});

  Future<void> _openExamExtraction(BuildContext context) async {
    await Navigator.pushNamed(context, Routes.examExtraction);
    if (context.mounted) {
      MyExamsCubit.get(context).fetchExams(isRefresh: true);
    }
  }

  Future<void> _openDiagnosticTest(BuildContext context) async {
    final saved = await Navigator.pushNamed(context, Routes.diagnosticTest);
    if (saved == true && context.mounted) {
      MyExamsCubit.get(context).fetchExams(isRefresh: true);
    }
  }

  Future<void> _openNafsTest(BuildContext context) async {
    final saved = await Navigator.pushNamed(context, Routes.nationalExams);
    if (saved == true && context.mounted) {
      MyExamsCubit.get(context).fetchExams(isRefresh: true);
    }
  }

  Future<void> _confirmDelete(BuildContext context, int examId) async {
    final confirmed = await showPrimaryConfirmDialog(
      context,
      titleKey: 'confirm_delete',
      messageKey: 'delete_exam_msg',
    );
    if (confirmed && context.mounted) {
      MyExamsCubit.get(context).deleteExam(examId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = MyExamsCubit.get(context);

    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('home_tests'),
          style: TextStylesManager.bold18.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.quiz_outlined, color: ColorsManager.mainText),
            tooltip: appTranslation().get('my_custom_questions'),
            onPressed: () => context.push(Routes.customQuestions),
          ),
        ],
      ),
      body: BlocConsumer<MyExamsCubit, MyExamsState>(
        listenWhen: (previous, current) =>
            current is MyExamsActionSuccess ||
            current is MyExamsActionError ||
            current is MyExamsPreviewReady,
        listener: (context, state) async {
          if (state is MyExamsActionSuccess) {
            showPrimarySnackBar(context, state.message, isError: false);
          } else if (state is MyExamsActionError) {
            showPrimarySnackBar(context, state.message, isError: true);
          } else if (state is MyExamsPreviewReady) {
            await Navigator.pushNamed(
              context,
              Routes.examGenerationPreview,
              arguments: state.exam,
            );
            if (context.mounted) {
              MyExamsCubit.get(context).fetchExams(isRefresh: true);
            }
          }
        },
        buildWhen: (previous, current) =>
            current is MyExamsInitial ||
            current is MyExamsLoading ||
            current is MyExamsLoaded ||
            current is MyExamsError,
        builder: (context, state) {
          final loadedState =
              state is MyExamsLoaded ? state : cubit.lastLoaded;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                MyExamsHeaderWidget(
                  selectedTab: cubit.selectedTab,
                  onTabChanged: cubit.changeTab,
                  onSearchChanged: cubit.searchExams,
                  onExtractExamTap: () => _openExamExtraction(context),
                  onDiagnosticTestTap: () => _openDiagnosticTest(context),
                  onNafsTestTap: () => _openNafsTest(context),
                ),
                verticalSpace16,
                Expanded(
                  child: ConditionalBuilder(
                    loadingState:
                        state is MyExamsInitial || state is MyExamsLoading,
                    errorState: state is MyExamsError,
                    errorBuilder: (_) => PrimaryErrorView(
                      message: (state as MyExamsError).message,
                      onRetry: () => cubit.fetchExams(isRefresh: true),
                    ),
                    emptyState:
                        loadedState == null || loadedState.exams.data.isEmpty,
                    emptyBuilder: (_) => NoDataWidget(
                      title: appTranslation().get('no_exams_found'),
                      icon: Icons.assignment_outlined,
                    ),
                    successBuilder: (_) => MyExamsListView(
                      loadedState: loadedState!,
                      onConfirmDelete: (id) => _confirmDelete(context, id),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

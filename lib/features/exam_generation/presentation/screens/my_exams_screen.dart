import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_state.dart';
import 'package:moean/features/exam_generation/presentation/widgets/exam_list_item_widget.dart';
import 'package:moean/features/exam_generation/presentation/widgets/my_exams_header_widget.dart';
import 'package:moean/features/exam_generation/domain/usecases/get_exam_usecase.dart';
import 'package:moean/core/di/injections.dart';

class MyExamsScreen extends StatefulWidget {
  const MyExamsScreen({super.key});

  @override
  State<MyExamsScreen> createState() => _MyExamsScreenState();
}

class _MyExamsScreenState extends State<MyExamsScreen> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MyExamsCubit>().fetchExams(isRefresh: true);
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: 
      // AppBar(
      //   title: Text(
      //     appTranslation().get('my_exam'),
      //     style: TextStylesManager.bold18,
      //   ),
      //   backgroundColor: ColorsManager.background,
      //   elevation: 0,
      // ),
       AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
       title: Text(
         "الاختبارات السابقه",
          style: TextStylesManager.bold18,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.quiz_outlined, color: ColorsManager.mainText),
            onPressed: () {
              context.push(Routes.customQuestions);
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<MyExamsCubit, MyExamsState>(
          buildWhen: (previous, current) {
            return current is MyExamsInitial || 
                   current is MyExamsLoading || 
                   current is MyExamsLoaded || 
                   current is MyExamsError;
          },
          listener: (context, state) {
            if (state is MyExamsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is MyExamsActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is MyExamsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is MyExamsInitial || state is MyExamsLoading) {
              return Center(child: CircularProgressIndicator(color: ColorsManager.primaryColor));
            }

            if (state is MyExamsLoaded) {
              final loadedState = state;

              const double colTitle = 260;
              const double colStatus = 110;
              const double colQuestions = 110;
              const double colGrade = 110;
              const double colDate = 130;
              const double colActions = 280;
              const double totalWidth = colTitle + colStatus + colQuestions + colGrade + colDate + colActions;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    MyExamsHeaderWidget(
                      selectedTab: loadedState.selectedTab,
                      onTabChanged: (tab) => context.read<MyExamsCubit>().changeTab(tab),
                      onSearchChanged: (query) => context.read<MyExamsCubit>().searchExams(query),
                    ),
                    verticalSpace24,
                    Expanded(
                      child: ConditionalBuilder(
                        loadingState: false,
                        emptyState: loadedState.exams.data.isEmpty,
                        successBuilder: (context) => Container(
                          decoration: BoxDecoration(
                            color: ColorsManager.surfacePrimary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ColorsManager.borderLightGray),
                          ),
                          child: Scrollbar(
                            controller: _horizontalController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: totalWidth,
                                child: Column(
                                  children: [
                                    _buildTableHeader(colTitle, colStatus, colQuestions, colGrade, colDate, colActions),
                                    Expanded(
                                      child: ListView.separated(
                                        controller: _verticalController,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemCount: loadedState.exams.data.length,
                                        separatorBuilder: (_, _) => Divider(color: ColorsManager.borderLightGray, height: 1),
                                        itemBuilder: (context, index) {
                                          final exam = loadedState.exams.data[index];
                                          return ExamListItemWidget(
                                            exam: exam,
                                            colTitle: colTitle,
                                            colStatus: colStatus,
                                            colQuestions: colQuestions,
                                            colGrade: colGrade,
                                            colDate: colDate,
                                            colActions: colActions,
                                            onPublish: () => context.read<MyExamsCubit>().publishExam(exam.id),
                                            onDelete: () => _confirmDelete(context, exam.id),
                                            onView: () => _navigateToExamPreview(context, exam.id),
                                            onTap: () => _navigateToExamPreview(context, exam.id),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        emptyBuilder: (context) => Center(
                          child: Text(
                            appTranslation().get('no_exams_found'),
                            style: TextStylesManager.bold16.copyWith(color: ColorsManager.placeholder),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTableHeader(double c1, double c2, double c3, double c4, double c5, double c6) {
    final isDark = ColorsManager.isDark;
    final headerColor = isDark ? ColorsManager.backgroundDark : Colors.grey.withValues(alpha: 0.1);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: ColorsManager.borderLightGray)),
      ),
      child: Row(
        children: [
          _buildHeaderCell(appTranslation().get('title'), c1),
          _buildHeaderCell(appTranslation().get('status'), c2, alignCenter: true),
          _buildHeaderCell(appTranslation().get('questions_count'), c3, alignCenter: true),
          _buildHeaderCell(appTranslation().get('grade'), c4, alignCenter: true),
          _buildHeaderCell(appTranslation().get('last_update'), c5, alignCenter: true),
          _buildHeaderCell(appTranslation().get('actions'), c6, alignCenter: true),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width, {bool alignCenter = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Align(
          alignment: alignCenter ? Alignment.center : AlignmentDirectional.centerStart,
          child: Text(text, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int examId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(appTranslation().get('confirm_delete'), style: TextStylesManager.bold16),
        content: Text(appTranslation().get('delete_exam_msg'), style: TextStylesManager.medium14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(appTranslation().get('cancel'), style: TextStylesManager.medium14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<MyExamsCubit>().deleteExam(examId);
            },
            child: Text(appTranslation().get('delete'), style: TextStylesManager.bold14.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToExamPreview(BuildContext context, int examId) async {
    // Show loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => Center(child: CircularProgressIndicator(color: ColorsManager.primaryColor)));
    
    // Fetch full exam details to pass to ExamPreviewScreen
    final getExamUseCase = sl<GetExamUseCase>();
    final result = await getExamUseCase.execute(examId);
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message), backgroundColor: Colors.red));
        },
        (exam) {
          Navigator.pushNamed(context, Routes.examGenerationPreview, arguments: exam).then((_) {
            if (context.mounted) {
              context.read<MyExamsCubit>().fetchExams(isRefresh: true);
            }
          });
        },
      );
    }
  }
}

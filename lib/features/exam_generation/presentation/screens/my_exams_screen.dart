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
  final ScrollController _verticalController = ScrollController();
  int? _expandedExamId;
  MyExamsLoaded? _lastLoadedState;

  @override
  void initState() {
    super.initState();
    context.read<MyExamsCubit>().fetchExams(isRefresh: true);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  void _toggleExpand(int examId) {
    setState(() {
      _expandedExamId = _expandedExamId == examId ? null : examId;
    });
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
            icon: Icon(Icons.track_changes, color: ColorsManager.mainText),
            tooltip: appTranslation().get('diagnostic_title'),
            onPressed: () async {
              final saved = await Navigator.pushNamed(context, Routes.diagnosticTest);
              if (saved == true && context.mounted) context.read<MyExamsCubit>().fetchExams();
            },
          ),
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
              _lastLoadedState = state;
            }

            final loadedState = state is MyExamsLoaded ? state : _lastLoadedState;
            if (loadedState != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    MyExamsHeaderWidget(
                      selectedTab: loadedState.selectedTab,
                      onTabChanged: (tab) => context.read<MyExamsCubit>().changeTab(tab),
                      onSearchChanged: (query) => context.read<MyExamsCubit>().searchExams(query),
                    ),
                    verticalSpace16,
                    Expanded(
                      child: ConditionalBuilder(
                        loadingState: false,
                        emptyState: loadedState.exams.data.isEmpty,
                        successBuilder: (context) => RefreshIndicator(
                          color: ColorsManager.primaryColor,
                          onRefresh: () async {
                            context.read<MyExamsCubit>().fetchExams(isRefresh: true);
                          },
                          child: ListView.separated(
                            controller: _verticalController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: loadedState.exams.data.length,
                            separatorBuilder: (_, _) => verticalSpace12,
                            itemBuilder: (context, index) {
                              final exam = loadedState.exams.data[index];
                              return ExamListItemWidget(
                                key: ValueKey(exam.id),
                                exam: exam,
                                isExpanded: _expandedExamId == exam.id,
                                onToggleExpand: () => _toggleExpand(exam.id),
                                onPublish: () => context.read<MyExamsCubit>().publishExam(exam.id),
                                onDelete: () => _confirmDelete(context, exam.id),
                                onView: () => _navigateToExamPreview(context, exam.id),
                                onShareOnline: exam.questionsCount > 0
                                    ? () => Navigator.pushNamed(
                                          context,
                                          Routes.createOnlineTest,
                                          arguments: {'exam_id': exam.id, 'title': exam.title},
                                        )
                                    : null,
                              );
                            },
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

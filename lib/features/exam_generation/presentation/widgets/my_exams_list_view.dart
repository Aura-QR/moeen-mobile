import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_state.dart';
import 'package:moean/features/exam_generation/presentation/widgets/exam_list_item_widget.dart';

class MyExamsListView extends StatelessWidget {
  final MyExamsLoaded loadedState;
  final ValueChanged<int> onConfirmDelete;

  const MyExamsListView({
    super.key,
    required this.loadedState,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = MyExamsCubit.get(context);

    return Column(
      children: [
        if (loadedState.isPreviewLoading) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 3,
              color: ColorsManager.primaryColor,
              backgroundColor: ColorsManager.borderLightGray,
            ),
          ),
          verticalSpace8,
        ],
        Expanded(
          child: RefreshIndicator(
            color: ColorsManager.primaryColor,
            onRefresh: () => cubit.fetchExams(isRefresh: true),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: loadedState.exams.data.length,
              separatorBuilder: (_, _) => verticalSpace12,
              itemBuilder: (context, index) {
                final exam = loadedState.exams.data[index];
                return ExamListItemWidget(
                  key: ValueKey(exam.id),
                  exam: exam,
                  isExpanded: loadedState.expandedExamId == exam.id,
                  onToggleExpand: () => cubit.toggleExpand(exam.id),
                  onPublish: () => cubit.publishExam(exam.id),
                  onDelete: () => onConfirmDelete(exam.id),
                  onView: () => cubit.openExamPreview(exam.id),
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
        ),
      ],
    );
  }
}

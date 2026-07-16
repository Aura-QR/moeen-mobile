import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/admin/exams/domain/entities/admin_exam_entities.dart';
import 'package:moean/features/admin/exams/presentation/cubit/admin_exams_cubit.dart';
import 'package:moean/features/admin/exams/presentation/cubit/admin_exams_state.dart';

class AdminExamsScreen extends StatelessWidget {
  const AdminExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminExamsCubit, AdminExamsState>(
      listener: (context, state) {
        if (state is AdminExamReviewSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appTranslation().get('admin_exam_review_success')),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AdminExamReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AdminExamsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AdminExamsCubit>();
        final scrollController = ScrollController();

        scrollController.addListener(() {
          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200) {
            if (state is! AdminExamsLoading && cubit.currentPagination != null) {
              if (cubit.currentPagination!.currentPage < cubit.currentPagination!.lastPage) {
                cubit.fetchPendingQuestions(page: cubit.currentPagination!.currentPage + 1);
              }
            }
          }
        });

        List<AdminQuestionEntity> questions = [];
        if (cubit.currentPagination != null) {
          questions = cubit.currentPagination!.data;
        }

        return Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.primaryColor,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Icon(Icons.verified_outlined, color: Colors.white),
                horizontalSpace8,
                Text(
                  appTranslation().get('admin_pending_questions_title'),
                  style: TextStylesManager.bold18.copyWith(color: Colors.white),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => cubit.fetchPendingQuestions(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ColorsManager.primaryColor,
                  ),
                  onPressed: () {
                    context.push(Routes.home);
                  },
                  icon: const Icon(Icons.home),
                  label: Text(
                    appTranslation().get('home'),
                    style: TextStylesManager.medium16,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: (state is AdminExamsLoading && questions.isEmpty)
                        ? const Center(child: CircularProgressIndicator())
                        : questions.isEmpty
                            ? Center(
                                child: Text(
                                  appTranslation().get('no_pending_questions'),
                                  style: TextStylesManager.medium16,
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: questions.length + (state is AdminExamsLoading ? 1 : 0),
                                separatorBuilder: (context, index) => verticalSpace16,
                                itemBuilder: (context, index) {
                                  if (index >= questions.length) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final question = questions[index];
                                  return _buildQuestionCard(context, question, state);
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(BuildContext context, AdminQuestionEntity question, AdminExamsState state) {
    final cubit = context.read<AdminExamsCubit>();
    final isLoading = state is AdminExamReviewLoading && state.questionId == question.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  question.type.toUpperCase(),
                  style: TextStylesManager.medium12.copyWith(color: Colors.white),
                ),
                backgroundColor: ColorsManager.primaryColor,
              ),
              if (question.reviewStatus == 'pending')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    appTranslation().get('pending'),
                    style: TextStylesManager.medium12.copyWith(color: Colors.orange),
                  ),
                )
              else if (question.reviewStatus == 'approved')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    appTranslation().get('approved'),
                    style: TextStylesManager.medium12.copyWith(color: Colors.green),
                  ),
                )
              else if (question.reviewStatus == 'rejected')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    appTranslation().get('rejected'),
                    style: TextStylesManager.medium12.copyWith(color: Colors.red),
                  ),
                ),
            ],
          ),
          verticalSpace12,
          Text(
            question.questionText,
            style: TextStylesManager.bold16,
          ),
          verticalSpace12,
          _buildOptionsView(question),
          verticalSpace12,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                horizontalSpace8,
                Expanded(
                  child: Text(
                    "${appTranslation().get('correct_answer')}: ${question.correctAnswer}",
                    style: TextStylesManager.medium14.copyWith(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          verticalSpace12,
          if (question.creator != null)
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                horizontalSpace4,
                Text(
                  question.creator!.name,
                  style: TextStylesManager.regular14.copyWith(color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  "${appTranslation().get('difficulty')}: ${question.difficulty}",
                  style: TextStylesManager.regular14.copyWith(color: Colors.grey),
                ),
              ],
            ),
          if (question.reviewStatus == 'pending') ...[
            verticalSpace16,
            const Divider(),
            verticalSpace8,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  OutlinedButton.icon(
                    onPressed: () => cubit.reviewQuestion(question.id, 'rejected'),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: Text(
                      appTranslation().get('reject'),
                      style: TextStylesManager.medium14.copyWith(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  horizontalSpace12,
                  ElevatedButton.icon(
                    onPressed: () => cubit.reviewQuestion(question.id, 'approved'),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      appTranslation().get('approve'),
                      style: TextStylesManager.medium14.copyWith(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildOptionsView(AdminQuestionEntity question) {
    if (question.type == 'mcq' && question.options is List) {
      final options = question.options as List;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.radio_button_unchecked, size: 16, color: Colors.grey),
                horizontalSpace8,
                Expanded(
                  child: Text(
                    option.toString(),
                    style: TextStylesManager.regular14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (question.type == 'matching' && question.options != null) {
      try {
        final columnA = (question.options.columnA as List);
        final columnB = (question.options.columnB as List);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columnA.map((e) => Text("• $e")).toList(),
              ),
            ),
            horizontalSpace16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columnB.map((e) => Text("• $e")).toList(),
              ),
            ),
          ],
        );
      } catch (e) {
        return const SizedBox();
      }
    }
    return const SizedBox();
  }
}

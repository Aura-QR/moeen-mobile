import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/presentation/cubit/bank_questions_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/exam_info_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/lesson_selection_cubit.dart';

class BankQuestionsScreen extends StatefulWidget {
  const BankQuestionsScreen({super.key});

  @override
  State<BankQuestionsScreen> createState() => _BankQuestionsScreenState();
}

class _BankQuestionsScreenState extends State<BankQuestionsScreen> {
  int? _selectedLessonId;

  @override
  void initState() {
    super.initState();
    final selectedLessons = context.read<LessonSelectionCubit>().selectedLessons;
    if (selectedLessons.isNotEmpty) {
      _selectedLessonId = selectedLessons.first['id'] as int;
      context.read<BankQuestionsCubit>().loadQuestionsForLesson(_selectedLessonId!);
    }
  }

  void _onLessonSelected(int lessonId) {
    if (_selectedLessonId != lessonId) {
      setState(() {
        _selectedLessonId = lessonId;
      });
      context.read<BankQuestionsCubit>().loadQuestionsForLesson(lessonId);
    }
  }

  void _onContinue() {
    final selectedIdsMap = context.read<BankQuestionsCubit>().allSelectedQuestionIds;
    context.read<ExamInfoCubit>().updateSelectedBankQuestions(selectedIdsMap);
    context.pop(); // Return to QuestionCountsScreen
  }

  @override
  Widget build(BuildContext context) {
    final selectedLessons = context.read<LessonSelectionCubit>().selectedLessons;

    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'بنك الأسئلة',
          style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Lesson Selector
          if (selectedLessons.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: selectedLessons.length,
                separatorBuilder: (context, index) => horizontalSpace8,
                itemBuilder: (context, index) {
                  final lesson = selectedLessons[index];
                  final lessonId = lesson['id'] as int;
                  final isSelected = _selectedLessonId == lessonId;

                  return ChoiceChip(
                    label: Text(
                      lesson['name'],
                      style: isSelected 
                          ? TextStylesManager.bold12.copyWith(color: Colors.white)
                          : TextStylesManager.regular12.copyWith(color: ColorsManager.mainText),
                    ),
                    selected: isSelected,
                    selectedColor: ColorsManager.primaryColor,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? ColorsManager.primaryColor : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    onSelected: (_) => _onLessonSelected(lessonId),
                  );
                },
              ),
            ),
            
          Expanded(
            child: BlocBuilder<BankQuestionsCubit, BankQuestionsState>(
              builder: (context, state) {
                if (state is BankQuestionsLoading) {
                  return Center(child: CircularProgressIndicator(color: ColorsManager.primaryColor));
                }
                
                if (state is BankQuestionsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message, style: TextStylesManager.bold14.copyWith(color: ColorsManager.errorColor)),
                        verticalSpace16,
                        PrimaryElevatedButton(
                          text: 'إعادة المحاولة',
                          onPressed: () {
                            if (_selectedLessonId != null) {
                              context.read<BankQuestionsCubit>().loadQuestionsForLesson(_selectedLessonId!, refresh: true);
                            }
                          },
                        )
                      ],
                    ),
                  );
                }

                if (state is BankQuestionsUpdated) {
                  if (state.questions.isEmpty) {
                    return Center(
                      child: Text('لا توجد أسئلة متوفرة في بنك الأسئلة لهذا الدرس', 
                        style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: state.questions.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.questions.length) {
                        // Load more button
                        return TextButton(
                          onPressed: () => context.read<BankQuestionsCubit>().loadQuestionsForLesson(_selectedLessonId!),
                          child: Text('تحميل المزيد', style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor)),
                        );
                      }

                      final question = state.questions[index];
                      final isSelected = state.selectedQuestionIds.contains(question['id']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? ColorsManager.primaryColor.withValues(alpha: 0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? ColorsManager.primaryColor : Colors.grey.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => context.read<BankQuestionsCubit>().toggleQuestion(question['id']),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => context.read<BankQuestionsCubit>().toggleQuestion(question['id']),
                                  activeColor: ColorsManager.primaryColor,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              question['type'] ?? '',
                                              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                                            ),
                                          ),
                                          horizontalSpace8,
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              question['difficulty'] ?? 'متوسط',
                                              style: TextStylesManager.regular12.copyWith(color: ColorsManager.primaryColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      verticalSpace8,
                                      Text(
                                        question['question_text'] ?? '',
                                        style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                                      ),
                                    ],
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
                
                return const SizedBox.shrink();
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: BlocBuilder<BankQuestionsCubit, BankQuestionsState>(
                builder: (context, state) {
                  int selectedCount = 0;
                  if (state is BankQuestionsUpdated) {
                    selectedCount = state.allSelectedQuestionIds.values.fold(0, (sum, list) => sum + list.length);
                  }
                  return Column(
                    children: [
                      if (selectedCount > 0) ...[
                        Text(
                          'تم تحديد $selectedCount سؤال',
                          style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
                        ),
                        verticalSpace12,
                      ],
                      PrimaryElevatedButton(
                        text: 'تأكيد والعودة',
                        onPressed: _onContinue,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

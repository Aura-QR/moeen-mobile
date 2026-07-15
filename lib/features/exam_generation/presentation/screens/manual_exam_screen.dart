import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/exam_generation/presentation/cubit/manual_exam_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/manual_exam_state.dart';
import 'package:moean/features/exam_generation/presentation/widgets/manual_exam_type_selector.dart';
import 'package:moean/features/exam_generation/presentation/widgets/manual_exam_dynamic_form.dart';
import 'package:moean/core/di/injections.dart';

class ManualExamScreenArgs {
  final int examId;
  final Map<int, String> lessons; // lesson_id -> lesson_name

  ManualExamScreenArgs({
    required this.examId,
    required this.lessons,
  });
}

class ManualExamScreen extends StatelessWidget {
  const ManualExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // If arguments are missing, fallback for testing
    final args = ModalRoute.of(context)?.settings.arguments as ManualExamScreenArgs? ?? 
        ManualExamScreenArgs(examId: 1, lessons: {1: 'Lesson 1', 2: 'Lesson 2'});

    return BlocProvider(
      create: (context) => sl<ManualExamCubit>(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: ColorsManager.primaryColor,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              appTranslation().get('manual_exam_title'),
              style: TextStylesManager.bold18.copyWith(
                color: ColorsManager.mainText,
              ),
            ),
          ),
          body: BlocConsumer<ManualExamCubit, ManualExamState>(
            listener: (context, state) {
              if (state is ManualExamSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(appTranslation().get('question_added_success')),
                    backgroundColor: ColorsManager.primaryColor,
                  ),
                );
                context.pop(true); // Return true to indicate success
              } else if (state is ManualExamError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              final cubit = ManualExamCubit.get(context);
              
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ManualExamTypeSelector(
                          selectedType: cubit.selectedQuestionType,
                          onTypeSelected: cubit.changeQuestionType,
                        ),
                        verticalSpace24,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appTranslation().get('grade'),
                                    style: TextStylesManager.bold14.copyWith(
                                      color: ColorsManager.mainText,
                                    ),
                                  ),
                                  verticalSpace8,
                                  PrimaryTextField(
                                    controller: cubit.gradeController,
                                    keyboardType: TextInputType.number,
                                    hint: '',
                                  ),
                                ],
                              ),
                            ),
                            horizontalSpace16,
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appTranslation().get('related_lesson'),
                                    style: TextStylesManager.bold14.copyWith(
                                      color: ColorsManager.mainText,
                                    ),
                                  ),
                                  verticalSpace8,
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: ColorsManager.borderColor),
                                      borderRadius: BorderRadius.circular(12),
                                      color: ColorsManager.background,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: cubit.selectedLessonId,
                                        hint: Text(
                                          'اختر الدرس...',
                                          style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                                        ),
                                        isExpanded: true,
                                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: ColorsManager.mainText),
                                        items: args.lessons.entries.map((entry) {
                                          return DropdownMenuItem<int>(
                                            value: entry.key,
                                            child: Text(
                                              entry.value,
                                              style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) cubit.updateLesson(val);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        verticalSpace24,
                        Text(
                          appTranslation().get('question_text'),
                          style: TextStylesManager.bold14.copyWith(
                            color: ColorsManager.mainText,
                          ),
                        ),
                        verticalSpace8,
                        PrimaryTextField(
                          controller: cubit.questionTextController,
                          hint: appTranslation().get('write_question_text'),
                          maxLines: 4,
                        ),
                        verticalSpace24,
                        const ManualExamDynamicForm(),
                        verticalSpace64, // Space for bottom buttons
                        verticalSpace24,
                      ],
                    ),
                  ),
                  
                  // Bottom Buttons
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorsManager.background,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: PrimaryElevatedButton(
                              onPressed: () => cubit.submitQuestion(args.examId),
                              text: appTranslation().get('save_question'),
                              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                              isLoading: state is ManualExamLoading,
                            ),
                          ),
                          horizontalSpace16,
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: BorderSide(color: ColorsManager.borderColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                appTranslation().get('cancel'),
                                style: TextStylesManager.bold16.copyWith(
                                  color: ColorsManager.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

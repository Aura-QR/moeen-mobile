import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/exam_generation/presentation/cubit/manual_exam_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/manual_exam_state.dart';

class ManualExamDynamicForm extends StatelessWidget {
  const ManualExamDynamicForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManualExamCubit, ManualExamState>(
      builder: (context, state) {
        final cubit = ManualExamCubit.get(context);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cubit.selectedQuestionType == 'mcq') ...[
              _buildSectionTitle(appTranslation().get('options_one_per_line')),
              verticalSpace12,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorsManager.borderColor),
                  borderRadius: BorderRadius.circular(12),
                  color: ColorsManager.background,
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < cubit.optionsControllers.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: PrimaryTextField(
                                controller: cubit.optionsControllers[i],
                                hint: appTranslation().get('option_1').replaceAll('1', '${i + 1}'),
                              ),
                            ),
                            if (cubit.optionsControllers.length > 2) ...[
                              horizontalSpace8,
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => cubit.removeOption(i),
                              ),
                            ],
                          ],
                        ),
                      ),
                    TextButton.icon(
                      onPressed: cubit.addOption,
                      icon: Icon(Icons.add, color: ColorsManager.primaryColor),
                      label: Text(
                        appTranslation().get('add_option'),
                        style: TextStylesManager.medium14.copyWith(color: ColorsManager.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpace16,
            ],

            if (cubit.selectedQuestionType == 'matching') ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(appTranslation().get('column_b_one_per_line')),
                        verticalSpace12,
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorsManager.borderColor),
                            borderRadius: BorderRadius.circular(12),
                            color: ColorsManager.background,
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < cubit.columnBControllers.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: PrimaryTextField(
                                          controller: cubit.columnBControllers[i],
                                          hint: _getMatchingHint(i, true),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              TextButton.icon(
                                onPressed: cubit.addMatchingItem,
                                icon: Icon(Icons.add, color: ColorsManager.primaryColor),
                                label: Text(
                                  appTranslation().get('add_matching'),
                                  style: TextStylesManager.medium14.copyWith(color: ColorsManager.primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  horizontalSpace16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(appTranslation().get('column_a_one_per_line')),
                        verticalSpace12,
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorsManager.borderColor),
                            borderRadius: BorderRadius.circular(12),
                            color: ColorsManager.background,
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < cubit.columnAControllers.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: PrimaryTextField(
                                          controller: cubit.columnAControllers[i],
                                          hint: _getMatchingHint(i, false),
                                        ),
                                      ),
                                      if (cubit.columnAControllers.length > 2) ...[
                                        horizontalSpace8,
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () => cubit.removeMatchingItem(i),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Invisible button to align with Column B
                                Opacity(
                                  opacity: 0,
                                  child: TextButton.icon(
                                    onPressed: null,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Hidden'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              verticalSpace16,
            ],

            // Correct Answer Section
            _buildSectionTitle(appTranslation().get('correct_answer_model')),
            verticalSpace12,
            _buildCorrectAnswerInput(cubit),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStylesManager.bold14.copyWith(
        color: ColorsManager.mainText,
      ),
    );
  }

  String _getMatchingHint(int index, bool isColumnB) {
    if (isColumnB) {
      if (index == 0) return appTranslation().get('answer_a');
      if (index == 1) return appTranslation().get('answer_b');
      return appTranslation().get('distractor_c');
    } else {
      if (index == 0) return appTranslation().get('concept_1');
      if (index == 1) return appTranslation().get('concept_2');
      return '${index + 1}. المفهوم';
    }
  }

  Widget _buildCorrectAnswerInput(ManualExamCubit cubit) {
    if (cubit.selectedQuestionType == 'true_false') {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: ColorsManager.borderColor),
          borderRadius: BorderRadius.circular(12),
          color: ColorsManager.background,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: cubit.correctAnswerController.text.isEmpty ? null : cubit.correctAnswerController.text,
            hint: Text(
              appTranslation().get('write_correct_answer'),
              style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
            ),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: ColorsManager.mainText),
            items: [
              DropdownMenuItem(value: 'صح', child: Text(appTranslation().get('true_text'))),
              DropdownMenuItem(value: 'خطأ', child: Text(appTranslation().get('false_text'))),
            ],
            onChanged: (val) {
              if (val != null) {
                cubit.correctAnswerController.text = val;
                // Force rebuild
                // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
                cubit.emit(ManualExamFormUpdated());
              }
            },
          ),
        ),
      );
    }

    String hintText = appTranslation().get('write_correct_answer');
    if (cubit.selectedQuestionType == 'matching') {
      hintText = appTranslation().get('matching_example');
    }

    return PrimaryTextField(
      controller: cubit.correctAnswerController,
      hint: hintText,
      maxLines: cubit.selectedQuestionType == 'essay' ? 4 : 1,
    );
  }
}

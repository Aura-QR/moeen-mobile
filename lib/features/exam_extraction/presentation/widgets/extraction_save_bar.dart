import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/lesson_picker_sheet.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_cubit.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_review_state.dart';

class ExtractionSaveBar extends StatefulWidget {
  const ExtractionSaveBar({super.key});

  @override
  State<ExtractionSaveBar> createState() => _ExtractionSaveBarState();
}

class _ExtractionSaveBarState extends State<ExtractionSaveBar> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    final cubit = ExtractionReviewCubit.get(context);
    _titleController = TextEditingController(text: cubit.state.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExtractionReviewCubit, ExtractionReviewState>(
      buildWhen: (previous, current) =>
          previous.canSave != current.canSave ||
          previous.isSaving != current.isSaving ||
          previous.lesson != current.lesson,
      builder: (context, state) {
        final cubit = ExtractionReviewCubit.get(context);
        final lesson = state.lesson;
        final lessonText = lesson != null
            ? '${lesson.subjectName} — ${lesson.lessonTitle}'
            : appTranslation().get('exam_extract_pick_lesson');

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryTextField(
                  controller: _titleController,
                  label: appTranslation().get('exam_extract_exam_title'),
                  hint: appTranslation().get('exam_extract_exam_title'),
                  onChanged: (text) => cubit.setTitle(text),
                ),
                verticalSpace10,
                InkWell(
                  onTap: () async {
                    final picked = await LessonPickerSheet.show(context);
                    if (picked != null) {
                      cubit.setLesson(picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsManager.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: lesson != null
                            ? ColorsManager.primaryColor
                            : ColorsManager.borderLightGray,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          color: lesson != null
                              ? ColorsManager.primaryColor
                              : ColorsManager.secondaryText,
                          size: 20,
                        ),
                        horizontalSpace10,
                        Expanded(
                          child: Text(
                            lessonText,
                            style: TextStylesManager.medium13.copyWith(
                              color: lesson != null
                                  ? ColorsManager.mainText
                                  : ColorsManager.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: ColorsManager.secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),
                verticalSpace14,
                PrimaryElevatedButton(
                  text: appTranslation().get('exam_extract_save'),
                  isLoading: state.isSaving,
                  onPressed: state.canSave ? () => cubit.save() : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

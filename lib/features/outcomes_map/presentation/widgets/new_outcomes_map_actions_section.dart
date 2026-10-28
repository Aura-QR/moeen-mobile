import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/new_outcomes_map_cubit.dart';

/// Semester picker and «ابدأ» for the new outcomes map.
class NewOutcomesMapActionsSection extends StatelessWidget {
  final NewOutcomesMapState state;

  const NewOutcomesMapActionsSection({super.key, required this.state});

  /// «خريطة نواتج التعلم — {subject} — {semester}» built with the current locale.
  String _composeTitle() {
    final subject = state.selectedSubject?.name ?? '';
    final semester = appTranslation().get(OutcomesMapSemester.labelKey(state.semester));
    return '${appTranslation().get('outcomes_map_title')} — $subject — $semester';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = NewOutcomesMapCubit.get(context);
    const semesters = [OutcomesMapSemester.first, OutcomesMapSemester.second];
    final showCount = state.selectedSubject != null && !state.isLessonsLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimarySectionCard(
          icon: Icons.calendar_today_outlined,
          title: appTranslation().get('outcomes_map_semester_title'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryChoiceChips<String>(
                options: semesters,
                labelOf: (option) => appTranslation().get(OutcomesMapSemester.labelKey(option)),
                isSelected: (option) => option == state.semester,
                onTap: cubit.selectSemester,
              ),
              if (showCount) ...[
                verticalSpace10,
                Text(
                  state.semesterLessonCount > 0
                      ? '${appTranslation().get('outcomes_map_lessons_found')}: ${state.semesterLessonCount}'
                      : appTranslation().get('outcomes_map_no_lessons_semester'),
                  style: TextStylesManager.regular12.copyWith(
                    color: state.semesterLessonCount > 0
                        ? ColorsManager.secondaryText
                        : ColorsManager.errorColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        verticalSpace16,
        PrimaryElevatedButton(
          text: appTranslation().get('outcomes_map_start'),
          icon: const Icon(Icons.arrow_forward_rounded),
          onPressed: state.canStart ? () => cubit.start(_composeTitle()) : null,
        ),
      ],
    );
  }
}

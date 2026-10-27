import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_disclaimer_note.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_domains_selector.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_grade_chips.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_questions_count_slider.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_subject_chips.dart';

class NafsChooseView extends StatelessWidget {
  final NafsState state;

  const NafsChooseView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = NafsCubit.get(context);
    final subject = state.selectedSubject;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        NafsGradeChips(
          grades: state.grades,
          selectedGrade: state.selectedGrade,
        ),
        verticalSpace12,
        if (state.availableSubjects.isNotEmpty) ...[
          NafsSubjectChips(
            subjects: state.availableSubjects,
            selectedSubject: state.selectedSubject,
          ),
          verticalSpace12,
        ],
        if (subject != null && subject.domains.isNotEmpty) ...[
          NafsDomainsSelector(
            domains: subject.domains,
            selectedDomainIds: state.selectedDomainIds,
          ),
          verticalSpace12,
        ],
        NafsQuestionsCountSlider(
          count: state.questionsCount,
          isRealExam: state.isRealExam,
        ),
        verticalSpace12,
        const NafsDisclaimerNote(),
        verticalSpace20,
        PrimaryElevatedButton(
          text: appTranslation().get('nafs_generate_button'),
          onPressed: state.canGenerate ? cubit.generate : null,
        ),
        verticalSpace16,
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/tahsili/presentation/cubit/tahsili_cubit.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_disclaimer_note.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_domains_selector.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_questions_count_slider.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_subject_chips.dart';

class TahsiliChooseView extends StatelessWidget {
  final TahsiliState state;

  const TahsiliChooseView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = TahsiliCubit.get(context);
    final subject = state.selectedSubject;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsManager.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsManager.errorColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: ColorsManager.errorColor, size: 20),
                horizontalSpace8,
                Expanded(
                  child: Text(
                    appTranslation().get(state.error!),
                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.errorColor),
                  ),
                ),
                TextButton(
                  onPressed: cubit.generate,
                  child: Text(
                    appTranslation().get('tahsili_retry'),
                    style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          verticalSpace12,
        ],
        if (state.availableSubjects.isNotEmpty) ...[
          TahsiliSubjectChips(
            subjects: state.availableSubjects,
            selectedSubject: state.selectedSubject,
          ),
          verticalSpace12,
        ],
        if (subject != null && subject.domains.isNotEmpty) ...[
          TahsiliDomainsSelector(
            domains: subject.domains,
            selectedDomainIds: state.selectedDomainIds,
          ),
          verticalSpace12,
        ],
        TahsiliQuestionsCountSlider(
          count: state.questionsCount,
          limits: state.effectiveLimits,
        ),
        verticalSpace12,
        TahsiliDisclaimerNote(notice: state.options.notice),
        verticalSpace20,
        PrimaryElevatedButton(
          text: appTranslation().get('tahsili_generate_button'),
          onPressed: state.canGenerate ? cubit.generate : null,
        ),
        verticalSpace16,
      ],
    );
  }
}

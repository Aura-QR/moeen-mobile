import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';

/// The report's title, and «أنشئ بالذكاء الاصطناعي» (not yet available).
class ReportTitleSection extends StatelessWidget {
  const ReportTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.summarize_outlined,
      title: appTranslation().get('report_title_label'),
      child: BlocBuilder<ReportEditorCubit, ReportEditorState>(
        buildWhen: (previous, current) => previous.titleError != current.titleError,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryTextField(
              controller: cubit.titleController,
              hint: appTranslation().get('report_title_hint'),
              maxLength: state.limits.titleChars,
              onChanged: (_) => cubit.markTitleEdited(),
            ),
            if (state.titleError != null) ...[
              verticalSpace4,
              Text(
                appTranslation().get(state.titleError!),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
              ),
            ],
            verticalSpace8,
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(
                '${appTranslation().get('report_ai_generate')} (${appTranslation().get('report_soon')})',
                style: TextStylesManager.medium13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

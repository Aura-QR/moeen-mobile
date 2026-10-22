import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_report_section.dart';

/// One student: name and grade. «التالي» on the keyboard goes to the next
/// student's grade; an empty grade is «غائب».
class GradeStudentRow extends StatelessWidget {
  final int rowId;
  final int number;
  final bool nameRequired;

  const GradeStudentRow({super.key, required this.rowId, required this.number, required this.nameRequired});

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    final fields = cubit.editor.row(rowId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListenableBuilder(
        listenable: Listenable.merge([fields.grade, cubit.totalMarkController]),
        builder: (context, _) {
          final error = gradeError(fields.grade.text, cubit.totalMark);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 26,
                    child: Text('$number', style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor)),
                  ),
                  Expanded(
                    child: PrimaryTextField(
                      controller: fields.name,
                      hint: appTranslation().get(nameRequired ? 'grades_student_name' : 'grades_student_name_optional'),
                      maxLength: 120,
                    ),
                  ),
                  horizontalSpace8,
                  SizedBox(
                    width: 92,
                    child: PrimaryTextField(
                      controller: fields.grade,
                      focusNode: fields.gradeFocus,
                      hint: appTranslation().get('grades_absent'),
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: GradeReportSection.numberFormatters,
                      onFieldSubmitted: (_) => cubit.nextGradeFocus(rowId)?.requestFocus(),
                    ),
                  ),
                  IconButton(
                    tooltip: appTranslation().get('delete'),
                    onPressed: () => cubit.removeRow(rowId),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close_rounded, size: 18, color: ColorsManager.secondaryText),
                  ),
                ],
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 26, top: 4),
                  child: Text(
                    appTranslation().get(error),
                    style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

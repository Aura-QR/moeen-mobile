import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/presentation/widgets/document_option_selector.dart';
import 'package:moean/features/documents/presentation/widgets/document_picker_tile.dart';
import 'package:moean/features/grade_analysis/data/models/grade_options_model.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';

/// «التقرير»: سريع / مفصّل, and the test: المادة، الصف، الاختبار، التاريخ،
/// الدرجة الكلية، درجة النجاح.
class GradeReportSection extends StatelessWidget {
  const GradeReportSection({super.key});

  /// Digits (Latin or Arabic) and a decimal point or comma.
  static final List<TextInputFormatter> numberFormatters = [FilteringTextInputFormatter.allow(RegExp('[0-9٠-٩.,٫]'))];

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final cubit = GradeAnalysisCubit.get(context);
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (date != null) cubit.setDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.assignment_outlined,
      title: appTranslation().get('grades_section_report'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocSelector<GradeAnalysisCubit, GradeAnalysisState, String>(
            selector: (state) => state.reportType,
            builder: (context, type) => DocumentOptionSelector<String>(
              label: appTranslation().get('grades_field_report_type'),
              options: GradeReportTypes.all,
              selected: type,
              labelKeyOf: (type) => 'grades_report_type_$type',
              onChanged: cubit.setReportType,
            ),
          ),
          verticalSpace16,
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.subjectController,
                  label: appTranslation().get('strategy_field_subject'),
                  hint: appTranslation().get('strategy_field_subject_hint'),
                  maxLength: 120,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.gradeController,
                  label: appTranslation().get('strategy_field_grade'),
                  hint: appTranslation().get('strategy_field_grade_hint'),
                  maxLength: 120,
                ),
              ),
            ],
          ),
          verticalSpace12,
          PrimaryTextField(
            controller: cubit.testNameController,
            label: appTranslation().get('grades_field_test'),
            hint: appTranslation().get('grades_field_test_hint'),
            maxLength: 120,
          ),
          verticalSpace12,
          BlocSelector<GradeAnalysisCubit, GradeAnalysisState, DateTime?>(
            selector: (state) => state.date,
            builder: (context, date) => DocumentPickerTile(
              icon: Icons.event_outlined,
              hint: appTranslation().get('grades_field_date'),
              value: date == null ? null : isoDate(date),
              onTap: () => _pickDate(context, date),
            ),
          ),
          verticalSpace12,
          ListenableBuilder(
            listenable: cubit.totalMarkController,
            builder: (context, _) {
              final total = cubit.totalMark;
              final defaultPass = total == null ? null : total * cubit.state.options.passPercent / 100;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PrimaryTextField(
                      controller: cubit.totalMarkController,
                      label: appTranslation().get('grades_field_total'),
                      hint: appTranslation().get('grades_field_total_hint'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: numberFormatters,
                    ),
                  ),
                  horizontalSpace10,
                  Expanded(
                    child: PrimaryTextField(
                      controller: cubit.passMarkController,
                      label: appTranslation().get('grades_field_pass'),
                      hint: defaultPass == null
                          ? appTranslation().get('grades_field_pass_hint')
                          : appTranslation()
                                .get('grades_field_pass_default')
                                .replaceAll('{mark}', formatGrade(defaultPass)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: numberFormatters,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

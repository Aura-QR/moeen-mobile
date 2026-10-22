import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/student_picker_sheet.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_bulk_entry.dart';
import 'package:moean/features/grade_analysis/presentation/widgets/grade_student_row.dart';

/// The open class tab: its name, where the names come from, and the grades.
class GradeActiveClass extends StatelessWidget {
  const GradeActiveClass({super.key});

  Future<void> _pick(BuildContext context) async {
    final cubit = GradeAnalysisCubit.get(context);
    final active = cubit.state.active;
    if (active == null) return;
    final result = await StudentPickerSheet.show(
      context,
      initialClassId: active.classId,
      initialStudents: [for (final student in cubit.editor.students(active)) student.name],
    );
    if (result != null) cubit.setClassStudents(result);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    return BlocBuilder<GradeAnalysisCubit, GradeAnalysisState>(
      buildWhen: (previous, current) =>
          previous.active != current.active ||
          previous.reportType != current.reportType ||
          previous.classes.length != current.classes.length ||
          previous.isImporting != current.isImporting,
      builder: (context, state) {
        final active = state.active;
        if (active == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryTextField(
              key: ValueKey('class-name-${active.id}'),
              controller: cubit.editor.classFields(active.id).name,
              label: appTranslation().get('grades_field_class_name'),
              hint: appTranslation().get('grades_class_n').replaceAll('{n}', '${state.activeClass + 1}'),
              maxLength: 60,
            ),
            verticalSpace8,
            Wrap(
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _pick(context),
                  icon: const Icon(Icons.groups_2_outlined, size: 20),
                  label: Text(appTranslation().get('grades_pick_class')),
                ),
                TextButton.icon(
                  onPressed: state.isImporting ? null : cubit.importSheet,
                  icon: state.isImporting
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.upload_file_rounded, size: 20),
                  label: Text(appTranslation().get('grades_import_excel')),
                ),
                if (state.classes.length > 1)
                  TextButton.icon(
                    onPressed: () => cubit.removeClass(state.activeClass),
                    style: TextButton.styleFrom(foregroundColor: ColorsManager.errorColor),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    label: Text(appTranslation().get('grades_remove_class')),
                  ),
              ],
            ),
            if (!state.isDetailed)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: active.gradesOnly,
                onChanged: cubit.setGradesOnly,
                activeThumbColor: ColorsManager.primaryColor,
                title: Text(
                  appTranslation().get('grades_only_mode'),
                  style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                ),
                subtitle: Text(
                  appTranslation().get('grades_only_mode_note'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
              ),
            verticalSpace8,
            if (active.gradesOnly)
              GradeBulkEntry(key: ValueKey('bulk-${active.id}'), classId: active.id)
            else ...[
              for (var i = 0; i < active.rowIds.length; i++)
                GradeStudentRow(
                  key: ValueKey(active.rowIds[i]),
                  rowId: active.rowIds[i],
                  number: i + 1,
                  nameRequired: state.isDetailed,
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: cubit.addRow,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
                  label: Text(appTranslation().get('grades_add_student')),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';

/// «إدخال الدرجات فقط»: one grade per line, no names.
class GradeBulkEntry extends StatelessWidget {
  final int classId;

  const GradeBulkEntry({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    final controller = cubit.editor.classFields(classId).grades;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, cubit.totalMarkController]),
      builder: (context, _) {
        final lines = gradeLines(controller.text);
        final wrong = lines.where((line) => gradeError(line, cubit.totalMark) != null).length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryTextField(
              controller: controller,
              hint: appTranslation().get('grades_bulk_hint'),
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
            verticalSpace6,
            Text(
              wrong > 0
                  ? appTranslation().get('grades_bulk_wrong').replaceAll('{count}', '$wrong')
                  : appTranslation().get('grades_bulk_count').replaceAll('{count}', '${lines.length}'),
              style: TextStylesManager.regular12.copyWith(
                color: wrong > 0 ? ColorsManager.errorColor : ColorsManager.secondaryText,
              ),
            ),
          ],
        );
      },
    );
  }
}

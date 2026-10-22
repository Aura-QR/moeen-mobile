import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/grade_analysis/data/models/grade_sheet_import.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';

/// The names and grades read from a sheet, and the column the grades came
/// from, before they replace the class's rows. Pops with true to use them.
class GradeImportReviewSheet extends StatelessWidget {
  final GradeSheetImport sheet;

  const GradeImportReviewSheet({super.key, required this.sheet});

  static Future<bool> show(BuildContext context, GradeSheetImport sheet) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => GradeImportReviewSheet(sheet: sheet),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('grades_import_review_title'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace4,
              Text(
                appTranslation().get('grades_import_column').replaceAll('{column}', sheet.gradeColumn),
                style: TextStylesManager.medium13.copyWith(color: ColorsManager.primaryColor),
              ),
              verticalSpace4,
              Text(
                appTranslation().get('grades_import_review_subtitle').replaceAll('{count}', '${sheet.rows.length}'),
                style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace12,
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sheet.rows.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: ColorsManager.borderLightGray),
                  itemBuilder: (context, index) {
                    final row = sheet.rows[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${index + 1}',
                              style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              row.name,
                              style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                            ),
                          ),
                          Text(
                            row.grade == null ? appTranslation().get('grades_absent') : formatGrade(row.grade!),
                            style: TextStylesManager.bold14.copyWith(
                              color: row.grade == null ? ColorsManager.secondaryText : ColorsManager.mainText,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              verticalSpace16,
              PrimaryElevatedButton(
                text: appTranslation().get('grades_import_use'),
                icon: const Icon(Icons.playlist_add_check_rounded),
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(appTranslation().get('cancel'), style: TextStylesManager.bold14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

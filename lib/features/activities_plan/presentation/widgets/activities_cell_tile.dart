import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// One cell of a week: its column, the text, and «معدّل» once the teacher
/// changed the suggestion. Tap to edit.
class ActivitiesCellTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isEdited;
  final ValueChanged<String> onChanged;
  final VoidCallback onReset;

  const ActivitiesCellTile({
    super.key,
    required this.label,
    required this.text,
    required this.isEdited,
    required this.onChanged,
    required this.onReset,
  });

  Future<void> _edit(BuildContext context) async {
    final values = await PrimaryInputDialog.show(context, titleKey: 'activities_plan_edit_cell', fields: [
      PrimaryInputField(
        hintKey: 'activities_plan_cell_hint',
        initialValue: text,
        maxLines: 4,
        maxLength: 300,
        keyboardType: TextInputType.multiline,
      ),
    ]);
    if (values != null) onChanged(values.first);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: ColorsManager.background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _edit(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                            ),
                          ),
                          if (isEdited) ...[
                            horizontalSpace6,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: ColorsManager.secondaryColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                appTranslation().get('activities_plan_cell_edited'),
                                style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryColor),
                              ),
                            ),
                          ],
                        ],
                      ),
                      verticalSpace4,
                      Text(
                        text.isEmpty ? appTranslation().get('activities_plan_cell_empty') : text,
                        style: TextStylesManager.regular13.copyWith(
                          color: text.isEmpty ? ColorsManager.secondaryText : ColorsManager.mainText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isEdited)
                  IconButton(
                    tooltip: appTranslation().get('activities_plan_cell_reset'),
                    onPressed: onReset,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.restart_alt_rounded, size: 20, color: ColorsManager.secondaryText),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.edit_outlined, size: 18, color: ColorsManager.secondaryText),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

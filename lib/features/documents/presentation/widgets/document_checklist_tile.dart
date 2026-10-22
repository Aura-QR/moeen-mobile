import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/checklist_models.dart';

/// One tickable line. AI lines carry «مقترح»; the teacher's own lines can be
/// edited and deleted.
class DocumentChecklistTile extends StatelessWidget {
  final ChecklistLine line;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const DocumentChecklistTile({
    super.key,
    required this.line,
    required this.onToggle,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isSuggested = line.origin == ChecklistOrigin.suggested;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: line.isChecked ? ColorsManager.primaryColor.withValues(alpha: 0.06) : ColorsManager.background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: line.isChecked ? ColorsManager.primaryColor.withValues(alpha: 0.35) : ColorsManager.borderLightGray,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: line.isChecked,
                  onChanged: (_) => onToggle(),
                  activeColor: ColorsManager.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      line.text,
                      style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                    ),
                  ),
                ),
                if (isSuggested) ...[
                  horizontalSpace6,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorsManager.secondaryColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 12, color: ColorsManager.secondaryColor),
                        horizontalSpace4,
                        Text(
                          appTranslation().get('plan_suggested'),
                          style: TextStylesManager.bold12.copyWith(color: ColorsManager.secondaryColor),
                        ),
                      ],
                    ),
                  ),
                  horizontalSpace6,
                ],
                if (line.isCustom) ...[
                  IconButton(
                    tooltip: appTranslation().get('edit'),
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.edit_outlined, size: 18, color: ColorsManager.secondaryText),
                  ),
                  IconButton(
                    tooltip: appTranslation().get('delete'),
                    onPressed: onRemove,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.close_rounded, size: 18, color: ColorsManager.secondaryText),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

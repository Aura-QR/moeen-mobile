import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/documents/data/models/checklist_models.dart';
import 'package:moean/features/documents/presentation/widgets/document_checklist_tile.dart';

/// A section of ready options, AI suggestions and the teacher's own lines.
/// Only the ticked lines are saved.
class DocumentChecklistSection extends StatelessWidget {
  final ChecklistSection section;
  final ValueChanged<int> onToggle;
  final ValueChanged<String> onAdd;
  final void Function(int index, String text) onEdit;
  final ValueChanged<int> onRemove;

  const DocumentChecklistSection({
    super.key,
    required this.section,
    required this.onToggle,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  Future<String?> _ask(BuildContext context, String titleKey, String initial) async {
    final values = await PrimaryInputDialog.show(context, titleKey: titleKey, fields: [
      PrimaryInputField(
        hintKey: 'document_list_line_hint',
        initialValue: initial,
        maxLines: 3,
        maxLength: section.maxLength,
      ),
    ]);
    return values?.first;
  }

  Future<void> _add(BuildContext context) async {
    final text = await _ask(context, 'plan_add_line', '');
    if (text != null) onAdd(text);
  }

  Future<void> _edit(BuildContext context, int index) async {
    final text = await _ask(context, 'document_list_edit_line', section.lines[index].text);
    if (text != null) onEdit(index, text);
  }

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.checklist_rounded,
      title: section.label,
      trailing: Text(
        '${section.checkedTexts.length}/${section.maxChecked}',
        style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < section.lines.length; i++)
            DocumentChecklistTile(
              key: ValueKey('${section.key}-$i-${section.lines[i].text}'),
              line: section.lines[i],
              onToggle: () => onToggle(i),
              onEdit: () => _edit(context, i),
              onRemove: () => onRemove(i),
            ),
          if (!section.isFull)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(appTranslation().get('plan_add_line')),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_editable_list_item.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// A list of lines the teacher can edit, add, delete, reorder and reset.
class PrimaryEditableList extends StatelessWidget {
  final String title;
  final List<String> items;
  final int maxItems;
  final int maxLength;
  final ValueChanged<String> onAdd;
  final void Function(int index, String text) onEdit;
  final ValueChanged<int> onRemove;

  /// [newIndex] is the final position, after removing the moved line.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// «استعادة النص الأصلي»; null hides it.
  final VoidCallback? onReset;

  /// Translation keys for the add button, the edit dialog and the line hint.
  final String addKey;
  final String editKey;
  final String hintKey;

  const PrimaryEditableList({
    super.key,
    required this.title,
    required this.items,
    required this.maxItems,
    required this.maxLength,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
    required this.onReorder,
    this.onReset,
    this.addKey = 'document_list_add_line',
    this.editKey = 'document_list_edit_line',
    this.hintKey = 'document_list_line_hint',
  });

  Future<String?> _ask(BuildContext context, String titleKey, String initial) async {
    final values = await PrimaryInputDialog.show(context, titleKey: titleKey, fields: [
      PrimaryInputField(hintKey: hintKey, initialValue: initial, maxLines: 3, maxLength: maxLength),
    ]);
    return values?.first;
  }

  Future<void> _add(BuildContext context) async {
    final text = await _ask(context, addKey, '');
    if (text != null) onAdd(text);
  }

  Future<void> _edit(BuildContext context, int index) async {
    final text = await _ask(context, editKey, items[index]);
    if (text != null) onEdit(index, text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
            ),
            Text(
              '${items.length}/$maxItems',
              style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
            ),
            if (onReset != null)
              IconButton(
                tooltip: appTranslation().get('document_reset_original'),
                onPressed: onReset,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.restart_alt_rounded, size: 20, color: ColorsManager.secondaryText),
              ),
          ],
        ),
        verticalSpace8,
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: items.length,
          onReorderItem: onReorder,
          itemBuilder: (context, index) => PrimaryEditableListItem(
            key: ValueKey('$index-${items[index]}'),
            index: index,
            text: items[index],
            onEdit: () => _edit(context, index),
            onRemove: () => onRemove(index),
          ),
        ),
        if (items.length < maxItems)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => _add(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(appTranslation().get(addKey)),
            ),
          ),
      ],
    );
  }
}

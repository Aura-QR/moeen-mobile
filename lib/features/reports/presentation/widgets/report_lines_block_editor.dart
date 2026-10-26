import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_editable_list.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';

/// A bullet or numbered list, or a checklist: one line per item.
class ReportLinesBlockEditor extends StatelessWidget {
  final ReportBlock block;

  const ReportLinesBlockEditor({super.key, required this.block});

  List<String> get _items => switch (block) {
        ListBlock(:final items) => items,
        ChecklistBlock(:final items) => items,
        _ => const [],
      };

  void _setItems(BuildContext context, List<String> items) {
    final current = block;
    ReportEditorCubit.get(context).updateBlock(switch (current) {
      ListBlock() => current.copyWith(items: items),
      ChecklistBlock() => current.copyWith(items: items),
      _ => current,
    });
  }

  @override
  Widget build(BuildContext context) {
    final limits = ReportEditorCubit.get(context).state.limits;
    final current = block;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryEditableList(
          title: appTranslation().get('report_items'),
          items: _items,
          maxItems: limits.listItems,
          maxLength: limits.itemChars,
          addKey: 'report_add_item',
          onAdd: (text) => _setItems(context, _items.addLine(text, limits.listItems)),
          onEdit: (index, text) => _setItems(context, _items.editLine(index, text)),
          onRemove: (index) => _setItems(context, _items.removeLine(index)),
          onReorder: (oldIndex, newIndex) => _setItems(context, _items.moveLine(oldIndex, newIndex)),
        ),
        if (current is ListBlock)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: current.ordered,
            activeThumbColor: ColorsManager.primaryColor,
            onChanged: (ordered) => ReportEditorCubit.get(context).updateBlock(current.copyWith(ordered: ordered)),
            title: Text(
              appTranslation().get('report_list_ordered'),
              style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
            ),
          ),
      ],
    );
  }
}

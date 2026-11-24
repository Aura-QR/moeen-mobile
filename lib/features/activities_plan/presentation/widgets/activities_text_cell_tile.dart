import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_cell_tile.dart';

/// A cell edited as free text: a domain of the old layout, or «المناسبات».
class ActivitiesTextCellTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isEdited;
  final ValueChanged<String> onChanged;
  final VoidCallback onReset;

  const ActivitiesTextCellTile({
    super.key,
    required this.label,
    required this.text,
    required this.isEdited,
    required this.onChanged,
    required this.onReset,
  });

  Future<void> _edit(BuildContext context) async {
    final values = await PrimaryInputDialog.show(
      context,
      titleKey: 'activities_plan_edit_cell',
      fields: [
        PrimaryInputField(
          hintKey: 'activities_plan_cell_hint',
          initialValue: text,
          maxLines: 4,
          maxLength: 300,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
    if (values != null) onChanged(values.first);
  }

  @override
  Widget build(BuildContext context) {
    return ActivitiesCellTile(
      label: label,
      text: text,
      isEdited: isEdited,
      onTap: () => _edit(context),
      onReset: onReset,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_settings_section.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_title_section.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_units_section.dart';

/// Scrollable body of the outcomes map editor.
class OutcomesMapEditorBody extends StatelessWidget {
  const OutcomesMapEditorBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const OutcomesMapTitleSection(),
        verticalSpace14,
        const OutcomesMapUnitsSection(),
        verticalSpace14,
        const OutcomesMapSettingsSection(),
      ],
    );
  }
}

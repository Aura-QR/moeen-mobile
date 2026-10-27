import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_outline_section.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_settings_section.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_map_title_section.dart';

/// Scrollable body of the concept map editor.
class ConceptMapEditorBody extends StatelessWidget {
  const ConceptMapEditorBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const ConceptMapTitleSection(),
        verticalSpace14,
        const ConceptMapOutlineSection(),
        verticalSpace14,
        const ConceptMapSettingsSection(),
      ],
    );
  }
}

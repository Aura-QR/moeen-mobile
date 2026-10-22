import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';

/// «ملاحظات» of a document.
class DocumentNotesSection extends StatelessWidget {
  final TextEditingController controller;

  const DocumentNotesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.sticky_note_2_outlined,
      title: appTranslation().get('strategy_section_notes'),
      child: PrimaryTextField(
        controller: controller,
        hint: appTranslation().get('strategy_notes_hint'),
        maxLines: 4,
        maxLength: 2000,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_cubit.dart';

class ExtractionNotesField extends StatefulWidget {
  const ExtractionNotesField({super.key});

  @override
  State<ExtractionNotesField> createState() => _ExtractionNotesFieldState();
}

class _ExtractionNotesFieldState extends State<ExtractionNotesField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryTextField(
      controller: _controller,
      label: appTranslation().get('exam_extract_notes_label'),
      hint: appTranslation().get('exam_extract_notes_label'),
      maxLines: 3,
      maxLength: 500,
      onChanged: (value) {
        ExtractionPagesCubit.get(context).setNotes(value);
      },
    );
  }
}

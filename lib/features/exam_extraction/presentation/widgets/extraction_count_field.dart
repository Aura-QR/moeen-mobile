import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_cubit.dart';

class ExtractionCountField extends StatefulWidget {
  const ExtractionCountField({super.key});

  @override
  State<ExtractionCountField> createState() => _ExtractionCountFieldState();
}

class _ExtractionCountFieldState extends State<ExtractionCountField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '10');
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
      label: appTranslation().get('exam_extract_count_label'),
      hint: '10',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          ExtractionPagesCubit.get(context).setCount(parsed);
        }
      },
    );
  }
}

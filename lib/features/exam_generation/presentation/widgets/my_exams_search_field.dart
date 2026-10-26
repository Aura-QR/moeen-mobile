import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';

class MyExamsSearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const MyExamsSearchField({
    super.key,
    required this.onChanged,
  });

  @override
  State<MyExamsSearchField> createState() => _MyExamsSearchFieldState();
}

class _MyExamsSearchFieldState extends State<MyExamsSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryTextField(
      controller: _controller,
      hint: appTranslation().get('search_exam_title'),
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      fillColor: ColorsManager.background,
      prefixIcon: Icon(
        Icons.search_rounded,
        color: ColorsManager.secondaryText,
      ),
    );
  }
}

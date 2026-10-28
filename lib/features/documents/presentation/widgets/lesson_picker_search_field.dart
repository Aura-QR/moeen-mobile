import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/documents/presentation/cubit/lesson_picker_cubit.dart';

/// Filters the current lesson-picker step by name.
class LessonPickerSearchField extends StatefulWidget {
  const LessonPickerSearchField({super.key});

  @override
  State<LessonPickerSearchField> createState() => _LessonPickerSearchFieldState();
}

class _LessonPickerSearchFieldState extends State<LessonPickerSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryTextField(
      controller: _controller,
      hint: appTranslation().get('search_hint'),
      textInputAction: TextInputAction.search,
      prefixIcon: Icon(Icons.search_rounded, color: ColorsManager.secondaryText),
      onChanged: LessonPickerCubit.get(context).search,
    );
  }
}

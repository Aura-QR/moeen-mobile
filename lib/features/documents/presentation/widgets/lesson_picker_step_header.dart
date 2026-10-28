import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

/// A back button with the current selection, shared by the grade, subject and
/// lesson steps of the lesson picker.
class LessonPickerStepHeader extends StatelessWidget {
  const LessonPickerStepHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      leading: IconButton(
        onPressed: onBack,
        icon: Icon(Icons.arrow_back_rounded, color: ColorsManager.mainText),
      ),
      title: Text(
        title,
        style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
      ),
      subtitle: subtitle == null || subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
    );
  }
}

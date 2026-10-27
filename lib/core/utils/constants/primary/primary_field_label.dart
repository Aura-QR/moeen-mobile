import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

/// A small section/field label used above inputs in the document tools.
class PrimaryFieldLabel extends StatelessWidget {
  /// A translation key.
  final String textKey;

  const PrimaryFieldLabel({super.key, required this.textKey});

  @override
  Widget build(BuildContext context) {
    return Text(
      appTranslation().get(textKey),
      style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
    );
  }
}

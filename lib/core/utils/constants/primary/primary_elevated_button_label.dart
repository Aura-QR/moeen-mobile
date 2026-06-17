import 'package:flutter/material.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';

class PrimaryElevatedButtonLabel extends StatelessWidget {
  final bool isLoading;
  final String text;
  final TextStyle? textStyle;

  const PrimaryElevatedButtonLabel({
    super.key,
    required this.isLoading,
    required this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      loadingState: isLoading,
      successBuilder: (context) => Text(
        text,
        style: textStyle ??
            TextStylesManager.bold14.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}

import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:flutter/material.dart';

class PrimaryElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Widget? icon;
  final double? width;
final BorderSide? borderSide;

  const PrimaryElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 52,
    this.radius = 24,
    this.backgroundColor = ColorsManager.primaryColor,
    this.textStyle,
    this.icon,
    this.width,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: icon == null
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.black.withValues(alpha: 0.04),
                animationDuration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
               shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(radius),
  side: borderSide ?? BorderSide.none,
),
              ),
              child: _buildLabel(context),
            )
          : ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.black.withValues(alpha: 0.04),
                animationDuration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(radius),
  side: borderSide ?? BorderSide.none,
),
              ),
              icon: icon,
              label: _buildLabel(context),
            ),
    );
  }

  Widget _buildLabel(BuildContext context) {
    return ConditionalBuilder(
      loadingState: isLoading,
      successBuilder: (context) => Text(
        text,
        style:
            textStyle ??
            TextStylesManager.bold14.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}

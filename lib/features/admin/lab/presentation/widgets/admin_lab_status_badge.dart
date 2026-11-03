import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

class AdminLabStatusBadge extends StatelessWidget {
  final String label;
  final bool isGreen;
  final bool isAlert;

  const AdminLabStatusBadge({
    super.key,
    required this.label,
    required this.isGreen,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAlert
        ? ColorsManager.errorColor
        : (isGreen ? ColorsManager.successColor : ColorsManager.placeholder);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStylesManager.medium10.copyWith(color: color),
      ),
    );
  }
}

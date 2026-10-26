import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

/// Small «✨» badge shown on AI-supported role documents.
class RoleAiBadge extends StatelessWidget {
  const RoleAiBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '✨',
        style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class MyExamsEntryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? accentColor;

  const MyExamsEntryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? ColorsManager.primaryColor;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              horizontalSpace10,
              Expanded(
                child: Text(
                  title,
                  style: TextStylesManager.bold13.copyWith(
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

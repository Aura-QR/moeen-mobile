import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PortfolioHeaderActionWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? color;

  const PortfolioHeaderActionWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? ColorsManager.primaryColor;
    return Expanded(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 22,
                child: isLoading
                    ? SizedBox(width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: tint))
                    : Icon(icon, color: tint, size: 22),
              ),
              verticalSpace4,
              Text(label, style: TextStylesManager.medium12.copyWith(color: tint)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';


class CertificateTemplateCardWidget extends StatelessWidget {
  final CertificateTemplateModel template;
  final bool isSelected;
  final VoidCallback onTap;

  const CertificateTemplateCardWidget({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.borderColor,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              _TemplateMiniPreview(template: template),
              if (isSelected)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateMiniPreview extends StatelessWidget {
  final CertificateTemplateModel template;

  const _TemplateMiniPreview({required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: template.bgColor,
      child: Column(
        children: [
          // Header bar
          Container(
            height: 28,
            color: template.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: template.accentColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: template.accentColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Title bar
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: template.primaryColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: template.primaryColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          // Student name placeholder
          Container(
            width: 70,
            height: 14,
            decoration: BoxDecoration(
              color: template.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          // Text lines
          Container(
            width: 55,
            height: 3,
            decoration: BoxDecoration(
              color: template.primaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 45,
            height: 3,
            decoration: BoxDecoration(
              color: template.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Spacer(),
          // Footer divider
          Container(height: 1, color: template.accentColor),
          Container(
            height: 14,
            color: template.primaryColor.withValues(alpha: 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    width: 20, height: 3, color: template.primaryColor.withValues(alpha: 0.4)),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: template.primaryColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                    width: 20, height: 3, color: template.primaryColor.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

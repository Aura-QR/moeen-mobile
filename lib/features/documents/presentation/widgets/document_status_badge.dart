import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

/// «مسودة» or «نهائي».
class DocumentStatusBadge extends StatelessWidget {
  final bool isFinal;

  const DocumentStatusBadge({super.key, required this.isFinal});

  @override
  Widget build(BuildContext context) {
    final color = isFinal ? ColorsManager.successColor : ColorsManager.statusWarning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(
        appTranslation().get(isFinal ? 'document_status_final' : 'document_status_draft'),
        style: TextStylesManager.medium10.copyWith(color: color),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

/// «بدون شواهد» or «N شواهد».
class PortfolioEvidenceBadgeWidget extends StatelessWidget {
  final int count;

  const PortfolioEvidenceBadgeWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = count == 0 ? ColorsManager.statusWarning : ColorsManager.successColor;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          count == 0
              ? appTranslation().get('portfolio_no_evidence')
              : appTranslation().get('portfolio_evidence_count').replaceAll('{n}', '$count'),
          style: TextStylesManager.medium10.copyWith(color: color),
        ),
      ),
    );
  }
}

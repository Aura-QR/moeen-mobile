import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/document_element_label.dart';
import 'package:moean/features/portfolio/data/models/portfolio_element_model.dart';

/// «العنصر N – title» with its weight, as the server sends them.
class PortfolioRoleFormRow extends StatelessWidget {
  final PortfolioElementModel element;

  const PortfolioRoleFormRow({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              elementLabel(element.title, element.number),
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText),
            ),
          ),
          if (element.weight != null) ...[
            horizontalSpace8,
            Text(
              appTranslation().get('performance_weight').replaceAll('{n}', '${element.weight}'),
              style: TextStylesManager.medium12.copyWith(color: ColorsManager.primaryColor),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/data/models/portfolio_element_model.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_role_form_row.dart';

/// The picked role's evaluation form: its elements with their weights, or a
/// note that the teacher adds their own items.
class PortfolioRoleFormPreview extends StatelessWidget {
  final List<PortfolioElementModel> form;

  const PortfolioRoleFormPreview({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            appTranslation().get('portfolio_role_form_title'),
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace8,
          if (form.isEmpty)
            Text(
              appTranslation().get('portfolio_role_form_empty'),
              style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
            ),
          for (final element in form) PortfolioRoleFormRow(element: element),
        ],
      ),
    );
  }
}

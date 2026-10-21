import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_completion_ring_widget.dart';

class PortfolioCardWidget extends StatelessWidget {
  final PortfolioModel portfolio;
  final VoidCallback onTap;

  const PortfolioCardWidget({super.key, required this.portfolio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final missing = portfolio.completion.included - portfolio.completion.complete;
    final isComplete = missing <= 0;

    return Material(
      color: ColorsManager.surfacePrimary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorsManager.borderLightGray),
          ),
          child: Row(
            children: [
              PortfolioCompletionRingWidget(percent: portfolio.completion.percent),
              horizontalSpace16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portfolio.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                    ),
                    verticalSpace4,
                    Text(
                      portfolio.roleLabel,
                      style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
                    ),
                    verticalSpace8,
                    Text(
                      isComplete
                          ? appTranslation().get('portfolio_complete')
                          : appTranslation().get('portfolio_missing_count').replaceAll('{n}', '$missing'),
                      style: TextStylesManager.medium12.copyWith(
                        color: isComplete ? ColorsManager.successColor : ColorsManager.statusWarning,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: ColorsManager.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/tahsili/data/models/tahsili_models.dart';

class TahsiliDomainCheckboxTile extends StatelessWidget {
  final TahsiliDomainOption domain;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const TahsiliDomainCheckboxTile({
    super.key,
    required this.domain,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withValues(alpha: 0.05)
              : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.borderLightGray,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: isSelected,
              activeColor: ColorsManager.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: onChanged,
            ),
            horizontalSpace8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    domain.name,
                    style: TextStylesManager.bold13.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                  if (domain.outcome.isNotEmpty) ...[
                    verticalSpace4,
                    Text(
                      domain.outcome,
                      style: TextStylesManager.regular12.copyWith(
                        color: ColorsManager.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

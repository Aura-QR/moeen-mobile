import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/nafs/data/models/nafs_models.dart';

class NafsDomainCheckboxTile extends StatelessWidget {
  final NafsDomainOption domain;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const NafsDomainCheckboxTile({
    super.key,
    required this.domain,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? ColorsManager.primaryColor.withValues(alpha: 0.05)
            : ColorsManager.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? ColorsManager.primaryColor.withValues(alpha: 0.4)
              : ColorsManager.borderLightGray,
          width: 1.1,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        activeColor: ColorsManager.primaryColor,
        checkColor: ColorsManager.surfacePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          domain.name,
          style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
        ),
        subtitle: domain.outcome.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  domain.outcome,
                  style: TextStylesManager.regular12.copyWith(
                    color: ColorsManager.secondaryText,
                    height: 1.4,
                  ),
                ),
              )
            : null,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}

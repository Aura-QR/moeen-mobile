import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

class RegionLegendRow extends StatelessWidget {
  final String selectedRegion;
  final void Function(String) onRegionChanged;

  const RegionLegendRow({
    super.key,
    required this.selectedRegion,
    required this.onRegionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text('نوع التوزيع:',
              style: TextStylesManager.regular12
                  .copyWith(color: ColorsManager.secondaryText)),
          const SizedBox(width: 6),
          RegionChip(
            label: 'عام',
            selected: selectedRegion == 'general',
            onTap: () => onRegionChanged('general'),
          ),
          const SizedBox(width: 6),
          RegionChip(
            label: 'المنطقة الغربية',
            selected: selectedRegion == 'west',
            onTap: () => onRegionChanged('west'),
          ),
          const Spacer(),
          LegendDot(color: ColorsManager.primaryColor, label: 'أسبوع دراسي'),
          const SizedBox(width: 4),
          const LegendDot(color: Colors.orange, label: 'إجازة'),
          const SizedBox(width: 4),
          LegendDot(color: ColorsManager.errorColor, label: 'اختبار'),
        ],
      ),
    );
  }
}

class RegionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const RegionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? ColorsManager.primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                selected ? ColorsManager.primaryColor : ColorsManager.borderLightGray,
          ),
        ),
        child: Text(
          label,
          style: TextStylesManager.regular12.copyWith(
            color: selected
                ? ColorsManager.primaryColor
                : ColorsManager.secondaryText,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const LegendDot({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 2),
        Text(label,
            style: TextStylesManager.regular12
                .copyWith(color: ColorsManager.secondaryText, fontSize: 9)),
      ],
    );
  }
}

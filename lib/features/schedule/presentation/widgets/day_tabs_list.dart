import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/widgets/day_tab_item.dart';

class DayTabsList extends StatelessWidget {
  final List<DayModel> days;
  final int selectedIndex;
  final Function(int) onDaySelected;

  const DayTabsList({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        children: List.generate(days.length, (index) {
          return Expanded(
            child: DayTabItem(
              day: days[index],
              isSelected: index == selectedIndex,
              onTap: () => onDaySelected(index),
            ),
          );
        }),
      ),
    );
  }
}

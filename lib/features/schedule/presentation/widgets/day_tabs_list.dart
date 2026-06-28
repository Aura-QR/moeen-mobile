import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/spacing.dart'; // تأكد من استدعاء ملف المسافات
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/widgets/day_tab_item.dart';
import 'package:moean/features/schedule/presentation/cubit/schedule_cubit.dart';

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
    return Row(
      children: [

        // IconButton(
        //   padding: EdgeInsets.zero,
        //   constraints: const BoxConstraints(), // 🔥 هذا السطر يلغي المساحة الافتراضية حول الأيقونة
        //   icon: const Icon(
        //     Icons.keyboard_arrow_right,
        //     size: 24,
        //     color: ColorsManager.primaryDark,
        //   ),
        //   onPressed: () => ScheduleCubit.get(context).previousWeek(),
        // ),
        GestureDetector(
          onTap: () => ScheduleCubit.get(context).previousWeek(),
          child: const Icon(
            Icons.keyboard_arrow_right,
            size: 24,
            color: ColorsManager.primaryDark,
          ),    
        ),

        Expanded(
          child: Container(
            height: 88,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: ColorsManager.surfacePrimary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ColorsManager.borderColor),
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
          ),
        ),


        // IconButton(
        //   padding: EdgeInsets.zero,
        //   constraints: const BoxConstraints(), // 🔥 هذا السطر يلغي المساحة الافتراضية حول الأيقونة
        //   icon: const Icon(
        //     Icons.keyboard_arrow_left,
        //     size: 24,
        //     color: ColorsManager.primaryDark,
        //   ),
        //   onPressed: () => ScheduleCubit.get(context).nextWeek(),
        // ),
        GestureDetector(
          onTap: () => ScheduleCubit.get(context).nextWeek(),
          child: const Icon(
            Icons.keyboard_arrow_left,
            size: 24,
            color: ColorsManager.primaryDark,
          ),    
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/home/presentation/cubit/home_cubit.dart';
import 'package:moean/features/home/presentation/widgets/home_category_chip_item_widget.dart';

class HomeCategoryChipsWidget extends StatelessWidget {
  const HomeCategoryChipsWidget({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {'key': 'cat_presentations', 'icon': Icons.slideshow_rounded},
    {'key': 'cat_exams', 'icon': Icons.check_box_outlined},
    {'key': 'cat_worksheets', 'icon': Icons.description_outlined},
    {'key': 'cat_lesson_plans', 'icon': Icons.calendar_today_outlined},
    {'key': 'cat_weekly_prep', 'icon': Icons.date_range_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, curr) => curr is HomeCategoryChanged,
      builder: (context, state) {
        final cubit = HomeCubit.get(context);
        return SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return HomeCategoryChipItemWidget(
                label: appTranslation().get(category['key'] as String),
                icon: category['icon'] as IconData,
                isSelected: cubit.selectedCategoryIndex == index,
                onTap: () => cubit.onCategorySelected(index),
              );
            },
          ),
        );
      },
    );
  }
}

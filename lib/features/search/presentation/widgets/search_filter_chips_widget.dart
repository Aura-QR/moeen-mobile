import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/search/presentation/cubit/search_cubit.dart';
import 'package:moean/features/search/presentation/cubit/search_state.dart';

class SearchFilterChipsWidget extends StatelessWidget {
  const SearchFilterChipsWidget({super.key});

  static const List<Map<String, String>> _filters = [
    {'key': 'all', 'labelKey': 'search_filter_all'},
    {'key': 'questions', 'labelKey': 'search_filter_questions'},
    {'key': 'resources', 'labelKey': 'search_filter_resources'},
    {'key': 'exams', 'labelKey': 'search_filter_exams'},
    {'key': 'lessons', 'labelKey': 'search_filter_lessons'},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        final cubit = context.read<SearchCubit>();
        final activeFilter = cubit.activeFilter;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _filters.map((filter) {
              final isActive = activeFilter == filter['key'];
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: _FilterChipItem(
                  label: appTranslation().get(filter['labelKey']!),
                  isActive: isActive,
                  onTap: () => cubit.changeFilter(filter['key']!),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? ColorsManager.primaryColor
              : ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive
                ? ColorsManager.primaryColor
                : ColorsManager.borderColor,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color:
                        ColorsManager.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStylesManager.bold13.copyWith(
            color: isActive ? ColorsManager.white : ColorsManager.textPrimary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/home/presentation/cubit/home_cubit.dart';
import 'package:moean/features/home/presentation/widgets/home_app_bar_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_category_chips_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_featured_section_header_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_hero_banner_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_resource_card_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_search_bar_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_tip_of_day_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                verticalSpace8,
                const HomeAppBarWidget(),
                verticalSpace16,
                const HomeHeroBannerWidget(),
                verticalSpace20,
                const HomeSearchBarWidget(),
                verticalSpace20,
                const HomeCategoryChipsWidget(),
                verticalSpace24,
                const HomeFeaturedSectionHeaderWidget(),
                verticalSpace16,
                const _FeaturedResourcesList(),
                verticalSpace20,
                const HomeTipOfDayWidget(),
                verticalSpace32,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedResourcesList extends StatelessWidget {
  const _FeaturedResourcesList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        children:  [
          SizedBox(
            width: 220,
            child: HomeResourceCardWidget(
              typeKey: 'presentation_type',
              titleKey: 'resource_1_title',
              subjectKey: 'science',
              gradeKey: 'grade_4',
              usesCount: 2.5,
              typeColor:  ColorsManager.primaryColor,
              typeBgColor: Color(0xFFE8F5F0),
              typeIcon: Icons.bar_chart_rounded,
            ),
          ),
          horizontalSpace16,
          SizedBox(
            width: 220,
            child: HomeResourceCardWidget(
              typeKey: 'worksheet_type',
              titleKey: 'resource_2_title',
              subjectKey: 'math',
              gradeKey: 'grade_5',
              usesCount: 1.2,
              typeColor:  ColorsManager.primaryColor,

              typeBgColor: Color(0xFFF3EEFF),
              typeIcon: Icons.description_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

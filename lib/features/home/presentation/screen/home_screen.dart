import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/home/presentation/cubit/home_cubit.dart';
import 'package:moean/features/home/presentation/widgets/home_app_bar_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_hero_banner_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_tip_of_day_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_features_section_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return Scaffold(
            backgroundColor: ColorsManager.background,
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                verticalSpace8,
                // ignore: prefer_const_constructors
                HomeAppBarWidget(),
                verticalSpace40,
                // ignore: prefer_const_constructors
                HomeHeroBannerWidget(),
                verticalSpace40,
                const HomeFeaturesSectionWidget(),
                verticalSpace40,
                // ignore: prefer_const_constructors
                HomeTipOfDayWidget(),
              ],
            ),
          ),
        ),
      );
    },
  ),
);
  }
}

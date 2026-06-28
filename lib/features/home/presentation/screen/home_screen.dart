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
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      
                      Color(0xFF24b998).withValues(alpha: 0.001),
                      ColorsManager.background,
                    ],
                    stops: const [0.0, 0.4],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 20,
                      top: 200,
                      height: 150,
                      width: 140,
                      child: CustomPaint(
                        painter: DotGridPainter(
                          color: ColorsManager.primaryColor.withValues(alpha: 0.15),
                          spacing: 16.0,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                    ),
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

class DotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  DotGridPainter({required this.color, this.spacing = 16.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.spacing != spacing;
  }
}

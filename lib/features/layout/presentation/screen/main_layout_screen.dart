import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/layout/presentation/cubit/layout_cubit.dart';
import 'package:moean/features/layout/presentation/cubit/layout_state.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LayoutCubit(),
      child: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (context, state) {
          var cubit = LayoutCubit.get(context);

          return Scaffold(
            backgroundColor: ColorsManager.background,
            body: cubit.screens[cubit.currentIndex],
            bottomNavigationBar: CurvedNavigationBar(
              key: cubit.bottomNavigationKey,
              index: cubit.currentIndex,
              height: 60.0,
              items: <Widget>[
                Icon(Icons.person, size: 30, color: cubit.currentIndex == 1 ? ColorsManager.white : ColorsManager.textPrimary),
                Icon(Icons.home, size: 30, color: cubit.currentIndex == 0 ? ColorsManager.white : ColorsManager.textPrimary),
                Icon(Icons.settings, size: 30, color: cubit.currentIndex == 2 ? ColorsManager.white : ColorsManager.textPrimary),
              ],
              color: ColorsManager.primaryColor,
              buttonBackgroundColor: ColorsManager.primaryColor,
              backgroundColor: Colors.transparent,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 300),
              onTap: (index) {
                cubit.changeBottomNav(index, context);
              },
              letIndexChange: (index) => true,
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/home/presentation/screen/home_screen.dart';
import 'package:moean/features/profile/presentation/screen/profile_screen.dart';
import 'package:moean/features/profile/presentation/screen/settings_screen.dart';
import 'package:moean/features/layout/presentation/cubit/layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutInitial());

  static LayoutCubit get(BuildContext context) => BlocProvider.of<LayoutCubit>(context);

  int currentIndex = 0;
  final GlobalKey<CurvedNavigationBarState> bottomNavigationKey = GlobalKey();

  List<Widget> screens = [
    const HomeScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  void changeBottomNav(int index, BuildContext context) {
    if (index == 1 || index == 2) {
      if (token == null || token!.isEmpty) {
        // Not logged in, prevent navigation to Profile or Settings
        bottomNavigationKey.currentState?.setPage(currentIndex);
        Navigator.pushNamed(context, Routes.login);
        return;
      }
    }
    currentIndex = index;
    emit(LayoutChangeBottomNavState());
  }
}

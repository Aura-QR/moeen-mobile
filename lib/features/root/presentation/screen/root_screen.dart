import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/home/presentation/screen/home_screen.dart';
import 'package:moean/features/root/presentation/widgets/custom_bottom_nav_bar.dart';

class RootScreen extends StatefulWidget {
  final int initialIndex;
  const RootScreen({super.key, this.initialIndex = 0});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  static const List<Widget> _screens = [
    HomeScreen(),
    _PlaceholderScreen(index: 1),
    _PlaceholderScreen(index: 2),
    _PlaceholderScreen(index: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: ColorsManager.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final int index;
  const _PlaceholderScreen({required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      body: Center(
        child: Text(
          'Tab $index',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

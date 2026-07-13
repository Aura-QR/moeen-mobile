import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class HomeActionChipWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const HomeActionChipWidget({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  State<HomeActionChipWidget> createState() => _HomeActionChipWidgetState();
}

class _HomeActionChipWidgetState extends State<HomeActionChipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final bool isClickable = widget.onTap != null;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: ColorsManager.surfacePrimary,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isClickable
                      ? ColorsManager.goldDark.withValues(alpha: 0.1 + (_animation.value * 0.4))
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withValues(
                      alpha: isClickable ? (0.05 + (_animation.value * 0.1)) : 0.05,
                    ),
                    blurRadius: isClickable ? (8 + (_animation.value * 6)) : 10,
                    spreadRadius: isClickable ? (_animation.value * 1.5) : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: ColorsManager.primaryColor, size: 20),
                  horizontalSpace8,
                  Text(
                    widget.title,
                    style: TextStylesManager.bold14.copyWith(
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

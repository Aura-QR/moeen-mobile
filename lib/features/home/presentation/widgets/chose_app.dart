import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/widgets/dot_grid_painter.dart';
import 'package:moean/features/home/presentation/widgets/chose_app_header.dart';
import 'package:moean/features/home/presentation/widgets/chose_app_option_card.dart';
import 'package:moean/features/home/presentation/widgets/chose_app_usage_card.dart';

class ChoseApp extends StatefulWidget {
  const ChoseApp({super.key});

  @override
  State<ChoseApp> createState() => _ChoseAppState();
}

class _ChoseAppState extends State<ChoseApp>
    with SingleTickerProviderStateMixin {
  // ── Local selection state ─────────────────────────────────────────────────
  // 0 = Browser Extension (active), 1 = Mobile App (coming soon / disabled)
  int _selected = 0;

  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _controller;

  // Stagger config: 4 items → header, card1, card2, button
  static const int _itemCount = 5;
  static const double _itemDuration = 0.60; // fraction of total per item
  static const double _stagger = 0.14;      // fraction offset between items

  late final List<Animation<Offset>> _slides;
  late final List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _slides = List.generate(_itemCount, (i) {
      final start = (i * _stagger).clamp(0.0, 1.0);
      final end = (start + _itemDuration).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _fades = List.generate(_itemCount, (i) {
      final start = (i * _stagger).clamp(0.0, 1.0);
      final end = (start + _itemDuration * 0.85).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _animated(int index, Widget child) {
    return SlideTransition(
      position: _slides[index],
      child: FadeTransition(
        opacity: _fades[index],
        child: child,
      ),
    );
  }

  void _onContinue() {
    if (_selected == 0) {
      Navigator.pushNamed(context, Routes.addextention);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: ColorsManager.mainText,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Image.asset(
                AssetsHelper.icon,
                width: 55,
                height: 55,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                ColorsManager.primaryColor.withValues(alpha: 0.08),
                ColorsManager.background,
              ],
              stops: const [0.0, 0.45],
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative: dot grid (top-right) ─────────────────────
              Positioned(
                right: 16,
                top: 80,
                height: 160,
                width: 150,
                child: CustomPaint(
                  painter: DotGridPainter(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.13),
                    spacing: 16,
                  ),
                ),
              ),

              // ── Decorative: dot grid (bottom-left) ───────────────────
              Positioned(
                left: 12,
                bottom: 120,
                height: 120,
                width: 110,
                child: CustomPaint(
                  painter: DotGridPainter(
                    color: ColorsManager.secondaryColor.withValues(alpha: 0.12),
                    spacing: 14,
                  ),
                ),
              ),

              // ── Decorative: glowing circle top-left ──────────────────
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorsManager.primaryColor.withValues(alpha: 0.07),
                  ),
                ),
              ),

              // ── Decorative: glowing circle bottom-right ───────────────
              Positioned(
                bottom: -80,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorsManager.secondaryColor.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // ── Main content ──────────────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Item 0 — Header
                      _animated(
                        0,
                        ChoseAppHeader(
                          title: appTranslation().get('chose_app_title'),
                          subtitle: appTranslation().get('chose_app_subtitle'),
                        ),
                      ),

                      verticalSpace40,

                      // Item 1 — Extension card
                      _animated(
                        1,
                        ChoseAppOptionCard(
                          icon: Icons.extension_rounded,
                          title: appTranslation()
                              .get('chose_app_extension_title'),
                          subtitle: appTranslation()
                              .get('chose_app_extension_subtitle'),
                          badge: appTranslation()
                              .get('chose_app_extension_badge'),
                          badgeActive: true,
                          isSelected: _selected == 0,
                          onTap: () => setState(() => _selected = 0),
                        ),
                      ),

                      verticalSpace16,

                      // Item 2 — Mobile app card (coming soon)
                      _animated(
                        2,
                        ChoseAppOptionCard(
                          icon: Icons.phone_iphone_rounded,
                          title: appTranslation().get('chose_app_app_title'),
                          subtitle:
                              appTranslation().get('chose_app_app_subtitle'),
                          badge: appTranslation().get('chose_app_app_badge'),
                          badgeActive: false,
                          isSelected: false,
                          isDisabled: true,
                          onTap: null,
                        ),
                      ),

                      verticalSpace24,

                      // Item 3 — How to use card
                      _animated(
                        3,
                        const ChoseAppUsageCard(),
                      ),

                      verticalSpace24,

                      // Item 4 — Continue button
                      _animated(
                        4,
                        PrimaryElevatedButton(
                          onPressed: _onContinue,
                          text: appTranslation().get('chose_app_continue'),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // verticalSpace16,

                      // // Coming-soon hint (no animation, appears after button)
                      // FadeTransition(
                      //   opacity: _fades[3],
                      //   child: Text(
                      //     appTranslation().get('chose_app_app_badge'),
                      //     textAlign: TextAlign.center,
                      //     style: TextStylesManager.regular12.copyWith(
                      //       color: ColorsManager.secondaryText,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
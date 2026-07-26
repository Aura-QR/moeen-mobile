import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ExtensionUsageSlider extends StatefulWidget {
  const ExtensionUsageSlider({super.key});

  @override
  State<ExtensionUsageSlider> createState() => _ExtensionUsageSliderState();
}

class _ExtensionUsageSliderState extends State<ExtensionUsageSlider>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;

  static const List<String> _images = [
    AssetsHelper.screen1,
    AssetsHelper.screen2,
    AssetsHelper.screen3,
    
  ];

  late final AnimationController _overlayController;
  late final Animation<double> _overlayFade;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _overlayFade = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    );
    _overlayController.forward();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _overlayController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _goNext() {
    if (_currentPage < _images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _goPrev() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _images.length - 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Full-screen page view ────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _SliderPage(imagePath: _images[index]);
              },
            ),

            // ── Top bar with close button only ───────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _overlayFade,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom bar: counter + dots + navigation ──────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _overlayFade,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Counter chip — centered above nav row
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              '${_currentPage + 1} / ${_images.length}',
                              style: TextStylesManager.bold14.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),

                         verticalSpace14,

                          // Nav row: prev | dots | next
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Prev button
                              _NavButton(
                                icon: Icons.arrow_forward_ios_rounded,
                                onTap: _goPrev,
                                enabled: _currentPage > 0,
                              ),

                              // Dot indicators
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    _images.length,
                                    (i) => _Dot(isActive: i == _currentPage),
                                  ),
                                ),
                              ),

                              // Next / Done button
                              _NavButton(
                                icon: isLast
                                    ? Icons.check_rounded
                                    : Icons.arrow_back_ios_rounded,
                                onTap: _goNext,
                                enabled: true,
                                isPrimary: isLast,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Swipe hint label (first page only) ───────────────────────
            if (_currentPage == 0)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _overlayFade,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.swipe_left_alt_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                          horizontalSpace6,
                          Text(
                            appTranslation().get('slider_swipe_hint'),
                            style: TextStylesManager.regular12.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Single page with image filling the screen ────────────────────────────────
class _SliderPage extends StatelessWidget {
  final String imagePath;

  const _SliderPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stack) => Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: ColorsManager.secondaryText,
            size: 64,
          ),
        ),
      ),
    );
  }
}

// ── Navigation arrow button ───────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool isPrimary;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary
              ? ColorsManager.primaryColor
              : enabled
                  ? Colors.white.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: isPrimary
                ? ColorsManager.primaryColor
                : Colors.white.withValues(alpha: enabled ? 0.35 : 0.12),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white38,
          size: 20,
        ),
      ),
    );
  }
}

// ── Page dot indicator ────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  final bool isActive;

  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive
            ? ColorsManager.primaryColor
            : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

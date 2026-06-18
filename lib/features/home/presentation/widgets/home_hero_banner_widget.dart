import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class HomeHeroBannerWidget extends StatelessWidget {
  const HomeHeroBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 240, 
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ColorsManager.primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryColor.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(AssetsHelper.img6), 
            fit: BoxFit.cover, 
          ),
        ),
        child: Stack(
          children: [
            const _HeroBannerDecoration(), 
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        Text(
                          appTranslation().get('home_hero_title'),
                          style: TextStylesManager.bold40.copyWith(
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        verticalSpace4,
                        Text(
                          appTranslation().get('home_hero_subtitle'), 
                          style: TextStylesManager.regular16.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        verticalSpace12,
                        Text(
                          appTranslation().get('home_hero_description'), 
                          style: TextStylesManager.regular14.copyWith(
                            color: Colors.white,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  
                  const Expanded(
                    flex: 5, 
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBannerDecoration extends StatelessWidget {
  const _HeroBannerDecoration();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

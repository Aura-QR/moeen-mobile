import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/home/presentation/widgets/home_action_chip_widget.dart';
import 'package:moean/features/home/presentation/widgets/home_feature_item_widget.dart';

class HomeFeaturesSectionWidget extends StatefulWidget {
  const HomeFeaturesSectionWidget({super.key});

  @override
  State<HomeFeaturesSectionWidget> createState() => _HomeFeaturesSectionWidgetState();
}

class _HomeFeaturesSectionWidgetState extends State<HomeFeaturesSectionWidget> {
  int _selectedFeatureIndex = 1; 
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Start Prep Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 22),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    if (token != null && token!.isNotEmpty) {
                   //   context.push(Routes.schedule);
                   context.push(Routes.choseapp);
                    } else {
                      context.push(Routes.login);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        appTranslation().get('home_start_prep'),
                        style: TextStylesManager.bold16.copyWith(
                          color: ColorsManager.white,
                        ),
                      ),
                      horizontalSpace8,
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: ColorsManager.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          verticalSpace40,

          // Action Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                HomeActionChipWidget(
                  icon: Icons.monitor,
                  title: appTranslation().get('home_reports'),
                ),
                horizontalSpace12,
                HomeActionChipWidget(
                  icon: Icons.description_outlined,
                  title: appTranslation().get('home_worksheets'),
                ),
                horizontalSpace12,
                HomeActionChipWidget(
                  icon: Icons.verified_outlined,
                  title: appTranslation().get('home_tests'),
                ),
              ],
            ),
          ),
          verticalSpace24,

         
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IntrinsicHeight( 
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: HomeFeatureItemWidget(
                      icon: Icons.menu_book_rounded,
                      iconColor: ColorsManager.primaryColor,
                      iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                      title: appTranslation().get('feature_curriculum_title'),
                      subtitle: appTranslation().get('feature_curriculum_subtitle'),
                      isHighlighted: _selectedFeatureIndex == 0,
                      onTap: () {
                        setState(() {
                          _selectedFeatureIndex = 0;
                        });
                      },
                    ),
                  ),
                  horizontalSpace8,
                  Expanded(
                    child: HomeFeatureItemWidget(
                      icon: Icons.access_time_filled,
                      iconColor: ColorsManager.primaryColor, 
                      iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                      title: appTranslation().get('feature_time_title'),
                      subtitle: appTranslation().get('feature_time_subtitle'),
                      isHighlighted: _selectedFeatureIndex == 1,
                      onTap: () {
                        setState(() {
                          _selectedFeatureIndex = 1;
                        });
                      },
                    ),
                  ),
                  horizontalSpace8,
                  
                  Expanded(
                    child: HomeFeatureItemWidget(
                      icon: Icons.shield_outlined,
                      iconColor: ColorsManager.primaryColor,
                      iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                      title: appTranslation().get('feature_security_title'),
                      subtitle: appTranslation().get('feature_security_subtitle'),
                      isHighlighted: _selectedFeatureIndex == 2,
                      onTap: () {
                        setState(() {
                          _selectedFeatureIndex = 2;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';

class HomeSearchSectionWidget extends StatelessWidget {
  const HomeSearchSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SearchSectionBadgeWidget(),
          verticalSpace16,
          const _SearchSectionHeaderWidget(),
          verticalSpace8,
          const _SearchSectionSubtitleWidget(),
          verticalSpace24,
          const _SearchPreviewFieldWidget(),
          verticalSpace16,
          const _SearchNowButtonWidget(),
        ],
      ),
    );
  }
}

class _SearchSectionBadgeWidget extends StatelessWidget {
  const _SearchSectionBadgeWidget();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: ColorsManager.borderColor),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: ColorsManager.primaryColor,
            ),
            horizontalSpace8,
            Text(
              appTranslation().get('search_section_badge'),
              style: TextStylesManager.bold13.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSectionHeaderWidget extends StatelessWidget {
  const _SearchSectionHeaderWidget();

  @override
  Widget build(BuildContext context) {
    return Text(
      appTranslation().get('search_section_title'),
      style: TextStylesManager.aldhaBold28.copyWith(
        color: ColorsManager.primaryColor,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _SearchSectionSubtitleWidget extends StatelessWidget {
  const _SearchSectionSubtitleWidget();

  @override
  Widget build(BuildContext context) {
    return Text(
      appTranslation().get('search_section_subtitle'),
      style: TextStylesManager.regular14.copyWith(
        color: ColorsManager.secondaryText,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _SearchPreviewFieldWidget extends StatelessWidget {
  const _SearchPreviewFieldWidget();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.search),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorsManager.borderColor),
          boxShadow: [
            BoxShadow(
              color: ColorsManager.primaryColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: ColorsManager.primaryColor,
              size: 22,
            ),
            horizontalSpace12,
            Expanded(
              child: Text(
                appTranslation().get('search_home_hint'),
                style: TextStylesManager.regular14.copyWith(
                  color: ColorsManager.placeholder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchNowButtonWidget extends StatelessWidget {
  const _SearchNowButtonWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: () => context.push(Routes.search),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.primaryColor,
          foregroundColor: ColorsManager.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          appTranslation().get('search_now'),
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.white,
          ),
        ),
      ),
    );
  }
}

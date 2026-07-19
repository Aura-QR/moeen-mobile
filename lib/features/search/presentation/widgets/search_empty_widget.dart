import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class SearchEmptyWidget extends StatelessWidget {
  final String query;

  const SearchEmptyWidget({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: ColorsManager.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            verticalSpace24,
            Text(
              appTranslation().get('search_empty_title'),
              style: TextStylesManager.bold18.copyWith(
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace8,
            Text(
              appTranslation().get('search_empty_subtitle'),
              style: TextStylesManager.regular14.copyWith(
                color: ColorsManager.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace8,
            Text(
              '"$query"',
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

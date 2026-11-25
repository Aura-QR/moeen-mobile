import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// «بنود إضافية»: the title above the items outside the role's form.
class PerformanceExtrasHeader extends StatelessWidget {
  const PerformanceExtrasHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.playlist_add_rounded, size: 20, color: ColorsManager.secondaryText),
        horizontalSpace8,
        Expanded(
          child: Text(
            appTranslation().get('performance_extra_items'),
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.secondaryText),
          ),
        ),
      ],
    );
  }
}

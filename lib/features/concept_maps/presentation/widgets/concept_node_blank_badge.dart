import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

/// Small badge showing «فراغ للطالب» on concept tiles.
class ConceptNodeBlankBadge extends StatelessWidget {
  const ConceptNodeBlankBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        appTranslation().get('concept_map_blank_tag'),
        style: TextStylesManager.medium10.copyWith(
          color: ColorsManager.primaryColor,
        ),
      ),
    );
  }
}

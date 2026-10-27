import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// Title and error alert banner for [ConceptNodeSheet].
class ConceptNodeSheetHeader extends StatelessWidget {
  final bool isRoot;
  final String? error;

  const ConceptNodeSheetHeader({
    super.key,
    required this.isRoot,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          appTranslation().get(
            isRoot ? 'concept_map_edit_main' : 'concept_map_edit_branch',
          ),
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        if (error != null) ...[
          verticalSpace10,
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorsManager.errorColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              appTranslation().get(error!),
              style: TextStylesManager.regular12.copyWith(
                color: ColorsManager.errorColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_node_blank_badge.dart';

/// Single concept row in the outline, indented by [level].
class ConceptOutlineTile extends StatelessWidget {
  final ConceptMapNode node;
  final int level;
  final bool canAddChild;
  final String? errorMessage;
  final VoidCallback onTap;
  final VoidCallback onAddBranch;

  const ConceptOutlineTile({
    super.key,
    required this.node,
    required this.level,
    required this.canAddChild,
    required this.onTap,
    required this.onAddBranch,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;
    final indent = ((level - 1) * 18.0).clamp(0.0, 54.0);
    final isEmptyText = node.text.trim().isEmpty;

    final border = Border.all(
      color: hasError
          ? ColorsManager.errorColor
          : (node.isRoot
                ? ColorsManager.primaryColor.withValues(alpha: 0.4)
                : ColorsManager.borderLightGray),
    );
    final background = hasError
        ? ColorsManager.errorColor.withValues(alpha: 0.06)
        : (node.isRoot
              ? ColorsManager.primaryColor.withValues(alpha: 0.08)
              : ColorsManager.background);

    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent, bottom: 8),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 6, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: border,
            ),
            child: Row(
              children: [
                Icon(
                  node.isRoot
                      ? Icons.hub_rounded
                      : Icons.subdirectory_arrow_left_rounded,
                  size: 18,
                  color: hasError
                      ? ColorsManager.errorColor
                      : ColorsManager.primaryColor,
                ),
                horizontalSpace8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!node.isRoot && node.link.trim().isNotEmpty) ...[
                        Text(
                          node.link.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStylesManager.medium12.copyWith(
                            color: ColorsManager.primaryColor,
                          ),
                        ),
                        verticalSpace2,
                      ],
                      Text(
                        isEmptyText
                            ? appTranslation().get(
                                node.isRoot
                                    ? 'concept_map_main_placeholder'
                                    : 'concept_map_branch_placeholder',
                              )
                            : node.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (node.isRoot
                                    ? TextStylesManager.bold14
                                    : TextStylesManager.medium13)
                                .copyWith(
                                  color: isEmptyText
                                      ? ColorsManager.secondaryText
                                      : ColorsManager.mainText,
                                ),
                      ),
                      if (node.blank) ...[
                        verticalSpace4,
                        const ConceptNodeBlankBadge(),
                      ],
                    ],
                  ),
                ),
                if (canAddChild)
                  IconButton(
                    tooltip: appTranslation().get('concept_map_add_branch'),
                    onPressed: onAddBranch,
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      size: 20,
                      color: ColorsManager.primaryColor,
                    ),
                  ),
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: ColorsManager.secondaryText,
                ),
                horizontalSpace4,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

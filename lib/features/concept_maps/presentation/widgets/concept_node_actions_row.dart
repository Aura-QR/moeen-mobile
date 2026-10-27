import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';

/// Action buttons inside [ConceptNodeSheet]: +branch, move up, move down, delete.
class ConceptNodeActionsRow extends StatelessWidget {
  final bool canAddChild;
  final bool canMoveUp;
  final bool canMoveDown;
  final bool canDelete;
  final int totalCount;
  final int childrenCount;
  final int level;
  final VoidCallback onAddBranch;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  const ConceptNodeActionsRow({
    super.key,
    required this.canAddChild,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.canDelete,
    required this.totalCount,
    required this.childrenCount,
    required this.level,
    required this.onAddBranch,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  String? _limitKey() {
    if (canAddChild) return null;
    if (totalCount >= ConceptMapLimits.maxNodes) {
      return 'concept_map_limit_total';
    }
    if (level >= ConceptMapLimits.maxLevel) return 'concept_map_limit_level';
    if (childrenCount >= ConceptMapLimits.maxChildrenPerNode) {
      return 'concept_map_limit_children';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final limitKey = _limitKey();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: canAddChild ? onAddBranch : null,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(appTranslation().get('concept_map_add_branch')),
            ),
            if (canDelete) ...[
              OutlinedButton.icon(
                onPressed: canMoveUp ? onMoveUp : null,
                icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                label: Text(appTranslation().get('concept_map_move_up')),
              ),
              OutlinedButton.icon(
                onPressed: canMoveDown ? onMoveDown : null,
                icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                label: Text(appTranslation().get('concept_map_move_down')),
              ),
              OutlinedButton.icon(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorsManager.errorColor,
                  side: BorderSide(
                    color: ColorsManager.errorColor.withValues(alpha: 0.4),
                  ),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(appTranslation().get('delete')),
              ),
            ],
          ],
        ),
        if (limitKey != null) ...[
          verticalSpace6,
          Text(
            appTranslation().get(limitKey),
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
        ],
      ],
    );
  }
}

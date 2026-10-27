import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/data/models/concept_map_models.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_map_editor_cubit.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_node_sheet.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_outline_tile.dart';

/// Indented outline of all concepts in the map (`nodes`, max 30).
class ConceptMapOutlineSection extends StatelessWidget {
  const ConceptMapOutlineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ConceptMapEditorCubit.get(context);
    return BlocBuilder<ConceptMapEditorCubit, ConceptMapEditorState>(
      buildWhen: (previous, current) =>
          previous.input.nodes != current.input.nodes ||
          previous.nodeErrors != current.nodeErrors,
      builder: (context, state) {
        final nodes = state.input.nodes;
        return PrimarySectionCard(
          icon: Icons.account_tree_outlined,
          title: appTranslation().get('concept_map_outline_title'),
          trailing: Text(
            '${nodes.length}/${ConceptMapLimits.maxNodes}',
            style: TextStylesManager.medium12.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('concept_map_outline_hint'),
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.secondaryText,
                ),
              ),
              verticalSpace12,
              for (final node in nodes)
                ConceptOutlineTile(
                  node: node,
                  level: state.input.levelOf(node.id),
                  canAddChild: state.input.canAddChild(node.id),
                  errorMessage: state.nodeErrors[node.id],
                  onTap: () => ConceptNodeSheet.show(
                    context,
                    cubit: cubit,
                    nodeId: node.id,
                  ),
                  onAddBranch: () => cubit.addBranch(node.id),
                ),
            ],
          ),
        );
      },
    );
  }
}

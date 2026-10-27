import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_map_editor_cubit.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_node_actions_row.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_node_fields.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_node_sheet_header.dart';

/// Bottom sheet for editing a concept node's text, link words, student blank, and tree actions.
class ConceptNodeSheet extends StatefulWidget {
  final String nodeId;
  const ConceptNodeSheet({super.key, required this.nodeId});

  static Future<void> show(
    BuildContext context, {
    required ConceptMapEditorCubit cubit,
    required String nodeId,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ColorsManager.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: ConceptNodeSheet(nodeId: nodeId),
    ),
  );

  @override
  State<ConceptNodeSheet> createState() => _ConceptNodeSheetState();
}

class _ConceptNodeSheetState extends State<ConceptNodeSheet> {
  late final TextEditingController _textController;
  late final TextEditingController _linkController;
  late String _activeNodeId;

  @override
  void initState() {
    super.initState();
    _activeNodeId = widget.nodeId;
    final node = ConceptMapEditorCubit.get(
      context,
    ).state.input.nodeById(_activeNodeId);
    _textController = TextEditingController(text: node?.text ?? '');
    _linkController = TextEditingController(text: node?.link ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _switchToNewBranch(ConceptMapEditorCubit cubit) {
    final parentId = _activeNodeId;
    if (!cubit.state.input.canAddChild(parentId)) return;
    final newId = cubit.state.input.nextNodeId();
    final updated = cubit.state.input.addChild(parentId, id: newId);
    cubit.updateNode(parentId, text: _textController.text);
    setState(() {
      _activeNodeId = newId;
      _textController.clear();
      _linkController.clear();
    });
    cubit.addChildQuietly(updated);
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    ConceptMapEditorCubit cubit,
  ) async {
    final confirmed = await showPrimaryConfirmDialog(
      context,
      titleKey: 'concept_map_delete_node_title',
      messageKey: 'concept_map_delete_node_confirm',
    );
    if (!confirmed || !context.mounted) return;
    cubit.deleteNode(_activeNodeId);
    AppRouter.pop(null, context);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ConceptMapEditorCubit.get(context);
    return BlocBuilder<ConceptMapEditorCubit, ConceptMapEditorState>(
      buildWhen: (previous, current) =>
          previous.input != current.input ||
          previous.nodeErrors != current.nodeErrors,
      builder: (context, state) {
        final node = state.input.nodeById(_activeNodeId);
        if (node == null) return const SizedBox.shrink();
        final inset = MediaQuery.viewInsetsOf(context).bottom;

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + inset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConceptNodeSheetHeader(
                  isRoot: node.isRoot,
                  error: state.nodeErrors[_activeNodeId],
                ),
                verticalSpace14,
                ConceptNodeFields(
                  node: node,
                  textController: _textController,
                  linkController: _linkController,
                  onTextChanged: (v) =>
                      cubit.updateNode(_activeNodeId, text: v),
                  onLinkChanged: (v) =>
                      cubit.updateNode(_activeNodeId, link: v),
                  onBlankChanged: (v) =>
                      cubit.updateNode(_activeNodeId, blank: v),
                ),
                verticalSpace8,
                ConceptNodeActionsRow(
                  canAddChild: state.input.canAddChild(_activeNodeId),
                  canMoveUp: state.input.canMoveUp(_activeNodeId),
                  canMoveDown: state.input.canMoveDown(_activeNodeId),
                  canDelete: state.input.canDelete(_activeNodeId),
                  totalCount: state.input.nodes.length,
                  childrenCount: state.input.childrenOf(_activeNodeId).length,
                  level: state.input.levelOf(_activeNodeId),
                  onAddBranch: () => _switchToNewBranch(cubit),
                  onMoveUp: () => cubit.moveNodeUp(_activeNodeId),
                  onMoveDown: () => cubit.moveNodeDown(_activeNodeId),
                  onDelete: () => _confirmAndDelete(context, cubit),
                ),
                verticalSpace14,
                PrimaryElevatedButton(
                  text: appTranslation().get('concept_map_done'),
                  onPressed: () => AppRouter.pop(null, context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

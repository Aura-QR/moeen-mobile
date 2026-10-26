import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_add_block_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_block_card.dart';

/// The report's blocks, dragged by their handle, and «إضافة عنصر».
/// [keyOf] gives each card the key the editor scrolls to.
class ReportBlocksSection extends StatelessWidget {
  final GlobalKey Function(int blockId) keyOf;

  const ReportBlocksSection({super.key, required this.keyOf});

  Future<void> _add(BuildContext context) async {
    final cubit = ReportEditorCubit.get(context);
    final kind = await ReportAddBlockSheet.show(context, kinds: cubit.state.blockKinds, catalogue: cubit.state.catalogue);
    if (kind != null) cubit.addBlock(kind);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return BlocBuilder<ReportEditorCubit, ReportEditorState>(
      // Cards rebuild their own content; this follows the order only.
      buildWhen: (previous, current) =>
          previous.input.blocks.map((b) => b.id).join(',') != current.input.blocks.map((b) => b.id).join(','),
      builder: (context, state) {
        final blocks = state.input.blocks;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: blocks.length,
              onReorderItem: cubit.moveBlock,
              itemBuilder: (context, index) => KeyedSubtree(
                key: ValueKey(blocks[index].id),
                child: ReportBlockCard(key: keyOf(blocks[index].id), blockId: blocks[index].id, index: index),
              ),
            ),
            OutlinedButton.icon(
              onPressed: blocks.length < state.limits.blocks ? () => _add(context) : null,
              icon: const Icon(Icons.add_rounded),
              label: Text(appTranslation().get('report_add_block'), style: TextStylesManager.bold13),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorsManager.primaryColor,
                side: BorderSide(color: ColorsManager.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        );
      },
    );
  }
}

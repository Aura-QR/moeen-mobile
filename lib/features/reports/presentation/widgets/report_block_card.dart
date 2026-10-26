import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/report_block_style.dart';
import 'package:moean/features/reports/presentation/widgets/report_chart_editor.dart';
import 'package:moean/features/reports/presentation/widgets/report_columns_editor.dart';
import 'package:moean/features/reports/presentation/widgets/report_images_block_editor.dart';
import 'package:moean/features/reports/presentation/widgets/report_kv_editor.dart';
import 'package:moean/features/reports/presentation/widgets/report_lines_block_editor.dart';
import 'package:moean/features/reports/presentation/widgets/report_qr_editor.dart';
import 'package:moean/features/reports/presentation/widgets/report_table_editor.dart';
import 'package:moean/features/reports/presentation/widgets/report_text_block_editor.dart';

enum _BlockAction { duplicate, remove }

/// One block: its kind, a drag handle, «نسخ»/«حذف», then its editor.
/// Rebuilds only when this block, its error, or role-mode metadata changes.
class ReportBlockCard extends StatelessWidget {
  final int blockId;
  final int index;

  const ReportBlockCard({super.key, required this.blockId, required this.index});

  ReportBlock? _blockOf(ReportEditorState state) =>
      state.input.blocks.where((b) => b.id == blockId).firstOrNull;

  void _onAction(BuildContext context, _BlockAction action) {
    final cubit = ReportEditorCubit.get(context);
    switch (action) {
      case _BlockAction.duplicate:
        cubit.duplicateBlock(blockId);
      case _BlockAction.remove:
        cubit.removeBlock(blockId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportEditorCubit, ReportEditorState>(
      buildWhen: (previous, current) =>
          _blockOf(previous) != _blockOf(current) ||
          previous.blockErrors[blockId] != current.blockErrors[blockId] ||
          previous.isSensitive != current.isSensitive ||
          previous.roleTemplate?.namesColumn != current.roleTemplate?.namesColumn,
      builder: (context, state) {
        final block = _blockOf(state);
        if (block == null || (state.isSensitive && block is ImagesBlock)) {
          return const Offstage();
        }
        final error = state.blockErrors[blockId];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 12),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: error != null ? ColorsManager.errorColor : ColorsManager.borderLightGray,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_indicator_rounded, color: ColorsManager.secondaryText),
                  ),
                  horizontalSpace8,
                  Icon(reportBlockIcon(block.kind), size: 18, color: ColorsManager.primaryColor),
                  horizontalSpace6,
                  Expanded(
                    child: Text(
                      reportBlockLabel(block.kind, state.catalogue),
                      style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
                    ),
                  ),
                  PopupMenuButton<_BlockAction>(
                    icon: Icon(Icons.more_vert_rounded, color: ColorsManager.secondaryText),
                    onSelected: (action) => _onAction(context, action),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: _BlockAction.duplicate,
                        child: Text(appTranslation().get('report_duplicate')),
                      ),
                      PopupMenuItem(
                        value: _BlockAction.remove,
                        child: Text(appTranslation().get('delete')),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: switch (block) {
                  HeadingBlock() || ParagraphBlock() => ReportTextBlockEditor(block: block),
                  ListBlock() || ChecklistBlock() => ReportLinesBlockEditor(block: block),
                  TableBlock() => ReportTableEditor(block: block),
                  KvBlock() => ReportKvEditor(block: block),
                  ColumnsBlock() => ReportColumnsEditor(block: block),
                  ImagesBlock() => ReportImagesBlockEditor(block: block),
                  ChartBlock() => ReportChartEditor(block: block),
                  QrBlock() => ReportQrEditor(block: block),
                  PageBreakBlock() || UnknownBlock() => Text(
                      appTranslation().get(
                        block is PageBreakBlock ? 'report_page_break_hint' : 'report_unsupported_block',
                      ),
                      style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                    ),
                },
              ),
              if (error != null) ...[
                verticalSpace8,
                Text(
                  appTranslation().get(error),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.errorColor),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

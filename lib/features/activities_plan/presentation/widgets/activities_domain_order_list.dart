import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// The chosen domains as the table's columns, dragged into order.
class ActivitiesDomainOrderList extends StatelessWidget {
  final List<String> labels;

  /// [newIndex] is the final position, after removing the moved domain.
  final void Function(int oldIndex, int newIndex) onReorder;

  const ActivitiesDomainOrderList({super.key, required this.labels, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: labels.length,
      onReorderItem: onReorder,
      itemBuilder: (context, index) => Padding(
        key: ValueKey(labels[index]),
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: ColorsManager.background,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 4, 8),
            child: Row(
              children: [
                Text(
                  '${index + 1}',
                  style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                ),
                horizontalSpace10,
                Expanded(
                  child: Text(labels[index], style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText)),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.drag_indicator_rounded, size: 20, color: ColorsManager.secondaryText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

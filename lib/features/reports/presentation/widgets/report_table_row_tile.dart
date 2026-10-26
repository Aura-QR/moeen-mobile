import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

/// One table row as a compact strip of cells; tap to edit it.
class ReportTableRowTile extends StatelessWidget {
  final List<String> cells;
  final bool isHeader;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const ReportTableRowTile({super.key, required this.cells, required this.onTap, this.isHeader = false, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isHeader ? ColorsManager.primaryColor.withValues(alpha: 0.08) : null,
          border: Border(bottom: BorderSide(color: ColorsManager.borderLightGray)),
        ),
        child: Row(
          children: [
            for (final cell in cells)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Text(
                    cell.isEmpty ? '—' : cell,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: (isHeader ? TextStylesManager.bold12 : TextStylesManager.regular12).copyWith(
                      color: cell.isEmpty ? ColorsManager.secondaryText : ColorsManager.mainText,
                    ),
                  ),
                ),
              ),
            if (onRemove != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onRemove,
                icon: Icon(Icons.close_rounded, size: 16, color: ColorsManager.secondaryText),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.edit_outlined, size: 16, color: ColorsManager.secondaryText),
              ),
          ],
        ),
      ),
    );
  }
}

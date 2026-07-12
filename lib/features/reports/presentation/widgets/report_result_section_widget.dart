import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ReportResultSectionWidget extends StatelessWidget {
  final String sectionTitle;
  final List<Map<String, dynamic>> rows;
  final List<String> columnKeys;
  final List<String> columnLabels;
  final bool initiallyExpanded;

  const ReportResultSectionWidget({
    super.key,
    required this.sectionTitle,
    required this.rows,
    required this.columnKeys,
    required this.columnLabels,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.table_chart_outlined,
                color: ColorsManager.primaryColor,
                size: 18,
              ),
            ),
            title: Text(
              sectionTitle,
              style: TextStylesManager.bold14.copyWith(
                color: ColorsManager.mainText,
              ),
            ),
            subtitle: Text(
              '${rows.length} ${appTranslation().get('report_rows_count')}',
              style: TextStylesManager.regular12.copyWith(
                color: ColorsManager.secondaryText,
              ),
            ),
            children: [
              Divider(height: 1, color: ColorsManager.borderColor),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                child: _buildTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      border: TableBorder.all(
        color: ColorsManager.borderColor,
        borderRadius: BorderRadius.circular(8),
      ),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor,
          ),
          children: columnLabels
              .map(
                (label) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    label,
                    style: TextStylesManager.bold12.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
        // Data rows
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          final isEven = index % 2 == 0;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven
                  ? ColorsManager.background
                  : ColorsManager.surfacePrimary,
            ),
            children: columnKeys
                .map(
                  (key) => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Text(
                      (row[key] ?? '').toString(),
                      style: TextStylesManager.regular12.copyWith(
                        color: ColorsManager.mainText,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Print / PDF action bar
// ─────────────────────────────────────────────────────────────────────

class ReportPrintBarWidget extends StatelessWidget {
  final VoidCallback onPrint;

  const ReportPrintBarWidget({
    super.key,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryColor,
            ColorsManager.primaryColor.withValues(alpha: 0.85),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onPrint,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.print_rounded, color: Colors.white, size: 22),
            horizontalSpace10,
            Text(
              appTranslation().get('report_print'),
              style: TextStylesManager.bold16.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

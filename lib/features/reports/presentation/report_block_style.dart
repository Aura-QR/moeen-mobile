import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_catalogue_model.dart';

/// The icon of a block kind in the editor and the «إضافة» menu.
IconData reportBlockIcon(String kind) => switch (kind) {
      ReportBlockKinds.heading => Icons.title_rounded,
      ReportBlockKinds.paragraph => Icons.notes_rounded,
      ReportBlockKinds.list => Icons.format_list_bulleted_rounded,
      ReportBlockKinds.checklist => Icons.checklist_rounded,
      ReportBlockKinds.table => Icons.table_chart_outlined,
      ReportBlockKinds.kv => Icons.view_list_outlined,
      ReportBlockKinds.columns => Icons.view_column_outlined,
      ReportBlockKinds.images => Icons.photo_library_outlined,
      ReportBlockKinds.chart => Icons.bar_chart_rounded,
      ReportBlockKinds.qr => Icons.qr_code_2_rounded,
      ReportBlockKinds.pageBreak => Icons.insert_page_break_outlined,
      _ => Icons.help_outline_rounded,
    };

/// The server's label for [kind], or ours when the catalogue lacks it.
String reportBlockLabel(String kind, ReportCatalogueModel? catalogue) =>
    catalogue?.labelOf(kind) ?? appTranslation().get('report_kind_$kind');

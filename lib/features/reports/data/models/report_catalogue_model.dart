/// `GET /tools/reports`: templates, the «إضافة» menu and the limits.
library;

class ReportTemplateModel {
  final String key;
  final String label;
  final String description;

  const ReportTemplateModel({required this.key, required this.label, required this.description});

  factory ReportTemplateModel.fromJson(Map<String, dynamic> json) => ReportTemplateModel(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
      );
}

class ReportBlockKindModel {
  final String kind;
  final String label;

  const ReportBlockKindModel({required this.kind, required this.label});

  factory ReportBlockKindModel.fromJson(Map<String, dynamic> json) =>
      ReportBlockKindModel(kind: json['kind']?.toString() ?? '', label: json['label']?.toString() ?? '');
}

/// The server's limits; the defaults are the documented ones.
class ReportLimitsModel {
  final int blocks;
  final int meta;
  final int images;
  final int titleChars;
  final int textChars;
  final int itemChars;
  final int listItems;
  final int tableColumns;
  final int tableRows;
  final int kvPairs;
  final int chartLabels;
  final int chartSeries;

  const ReportLimitsModel({
    this.blocks = 60,
    this.meta = 8,
    this.images = 12,
    this.titleChars = 150,
    this.textChars = 3000,
    this.itemChars = 500,
    this.listItems = 30,
    this.tableColumns = 8,
    this.tableRows = 40,
    this.kvPairs = 20,
    this.chartLabels = 12,
    this.chartSeries = 4,
  });

  factory ReportLimitsModel.fromJson(Map<String, dynamic> json) {
    const fallback = ReportLimitsModel();
    int read(String key, int value) => json[key] is num ? (json[key] as num).toInt() : value;
    return ReportLimitsModel(
      blocks: read('blocks', fallback.blocks),
      meta: read('meta', fallback.meta),
      images: read('images', fallback.images),
      titleChars: read('title_chars', fallback.titleChars),
      textChars: read('text_chars', fallback.textChars),
      itemChars: read('item_chars', fallback.itemChars),
      listItems: read('list_items', fallback.listItems),
      tableColumns: read('table_columns', fallback.tableColumns),
      tableRows: read('table_rows', fallback.tableRows),
      kvPairs: read('kv_pairs', fallback.kvPairs),
      chartLabels: read('chart_labels', fallback.chartLabels),
      chartSeries: read('chart_series', fallback.chartSeries),
    );
  }
}

class ReportCatalogueModel {
  /// «تقرير فارغ» first.
  final List<ReportTemplateModel> templates;
  final List<ReportBlockKindModel> blockKinds;
  final ReportLimitsModel limits;

  const ReportCatalogueModel({required this.templates, required this.blockKinds, required this.limits});

  factory ReportCatalogueModel.fromJson(Map<String, dynamic> json) {
    final templates = json['templates'];
    final kinds = json['block_kinds'];
    final limits = json['limits'];
    return ReportCatalogueModel(
      templates: templates is List
          ? templates.whereType<Map>().map((t) => ReportTemplateModel.fromJson(Map<String, dynamic>.from(t))).toList()
          : const [],
      blockKinds: kinds is List
          ? kinds.whereType<Map>().map((k) => ReportBlockKindModel.fromJson(Map<String, dynamic>.from(k))).toList()
          : const [],
      limits: ReportLimitsModel.fromJson(limits is Map ? Map<String, dynamic>.from(limits) : const {}),
    );
  }

  /// The menu label from the server, or ours.
  String? labelOf(String kind) => blockKinds.where((k) => k.kind == kind).firstOrNull?.label;
}

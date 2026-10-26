/// The blocks a report is made of (DOCUMENTS_API.md § 12). Each kind keeps
/// only its own fields; [UnknownBlock] carries kinds this app doesn't know
/// yet, unchanged.
library;

import 'package:equatable/equatable.dart';

abstract final class ReportBlockKinds {
  static const String heading = 'heading';
  static const String paragraph = 'paragraph';
  static const String list = 'list';
  static const String checklist = 'checklist';
  static const String table = 'table';
  static const String kv = 'kv';
  static const String columns = 'columns';
  static const String images = 'images';
  static const String chart = 'chart';
  static const String qr = 'qr';
  static const String pageBreak = 'page_break';

  /// The «إضافة» menu when the catalogue didn't say otherwise.
  static const List<String> all = [heading, paragraph, list, checklist, table, kv, columns, images, chart, qr, pageBreak];
}

sealed class ReportBlock extends Equatable {
  /// A local id for the list's keys; never sent.
  final int id;

  const ReportBlock(this.id);

  String get kind;

  Map<String, dynamic> toJson();

  /// The same content under a new id, for «نسخ».
  ReportBlock withId(int id);

  /// A new block of [kind] with the fields the server requires.
  static ReportBlock empty(String kind, int id) => switch (kind) {
        ReportBlockKinds.heading => HeadingBlock(id),
        ReportBlockKinds.paragraph => ParagraphBlock(id),
        ReportBlockKinds.list => ListBlock(id),
        ReportBlockKinds.checklist => ChecklistBlock(id),
        ReportBlockKinds.table => TableBlock(id, columns: const ['', '']),
        ReportBlockKinds.kv => KvBlock(id),
        ReportBlockKinds.columns => ColumnsBlock(id, columns: const [ReportColumn(), ReportColumn()]),
        ReportBlockKinds.images => ImagesBlock(id),
        ReportBlockKinds.chart => ChartBlock(id, series: const [ReportSeries()]),
        ReportBlockKinds.qr => QrBlock(id),
        ReportBlockKinds.pageBreak => PageBreakBlock(id),
        _ => UnknownBlock(id, {'kind': kind}),
      };

  static ReportBlock fromJson(Map<String, dynamic> json, int id) => switch (json['kind']) {
        ReportBlockKinds.heading => HeadingBlock(id, text: _text(json['text'])),
        ReportBlockKinds.paragraph => ParagraphBlock(id, text: _text(json['text'])),
        ReportBlockKinds.list => ListBlock(id, items: _texts(json['items']), ordered: json['ordered'] == true),
        ReportBlockKinds.checklist => ChecklistBlock(id, items: _texts(json['items'])),
        ReportBlockKinds.table => TableBlock(
            id,
            columns: _texts(json['columns']).isEmpty ? const [''] : _texts(json['columns']),
            rows: json['rows'] is List ? (json['rows'] as List).map(_texts).toList() : const [],
            widths: json['widths'] is List
                ? (json['widths'] as List).map((w) => _number(w) ?? 1).toList()
                : const [],
            compact: json['compact'] == true,
            namesColumn: json['names_column'],
          ),
        ReportBlockKinds.kv => KvBlock(id, pairs: _maps(json['pairs']).map(ReportPair.fromJson).toList()),
        ReportBlockKinds.columns => ColumnsBlock(
            id,
            columns: _maps(json['columns']).map(ReportColumn.fromJson).toList(),
          ),
        ReportBlockKinds.images => ImagesBlock(
            id,
            items: _texts(json['items']),
            columns: (_number(json['columns'])?.toInt() ?? 2).clamp(1, 3),
          ),
        ReportBlockKinds.chart => ChartBlock(
            id,
            title: _text(json['title']),
            labels: _texts(json['labels']),
            series: _maps(json['series']).map(ReportSeries.fromJson).toList(),
            compact: json['compact'] == true,
          ),
        ReportBlockKinds.qr => QrBlock(id, url: _text(json['url']), caption: _text(json['caption'])),
        ReportBlockKinds.pageBreak => PageBreakBlock(id),
        _ => UnknownBlock(id, json),
      };
}

class HeadingBlock extends ReportBlock {
  final String text;

  const HeadingBlock(super.id, {this.text = ''});

  @override
  String get kind => ReportBlockKinds.heading;

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'text': text};

  @override
  HeadingBlock withId(int id) => HeadingBlock(id, text: text);

  HeadingBlock copyWith({String? text}) => HeadingBlock(id, text: text ?? this.text);

  @override
  List<Object?> get props => [id, text];
}

class ParagraphBlock extends ReportBlock {
  final String text;

  const ParagraphBlock(super.id, {this.text = ''});

  @override
  String get kind => ReportBlockKinds.paragraph;

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'text': text};

  @override
  ParagraphBlock withId(int id) => ParagraphBlock(id, text: text);

  ParagraphBlock copyWith({String? text}) => ParagraphBlock(id, text: text ?? this.text);

  @override
  List<Object?> get props => [id, text];
}

class ListBlock extends ReportBlock {
  final List<String> items;
  final bool ordered;

  const ListBlock(super.id, {this.items = const [], this.ordered = false});

  @override
  String get kind => ReportBlockKinds.list;

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'items': items, 'ordered': ordered};

  @override
  ListBlock withId(int id) => ListBlock(id, items: items, ordered: ordered);

  ListBlock copyWith({List<String>? items, bool? ordered}) =>
      ListBlock(id, items: items ?? this.items, ordered: ordered ?? this.ordered);

  @override
  List<Object?> get props => [id, items, ordered];
}

class ChecklistBlock extends ReportBlock {
  final List<String> items;

  const ChecklistBlock(super.id, {this.items = const []});

  @override
  String get kind => ReportBlockKinds.checklist;

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'items': items};

  @override
  ChecklistBlock withId(int id) => ChecklistBlock(id, items: items);

  ChecklistBlock copyWith({List<String>? items}) => ChecklistBlock(id, items: items ?? this.items);

  @override
  List<Object?> get props => [id, items];
}

class TableBlock extends ReportBlock {
  /// The header cells; at least one.
  final List<String> columns;
  final List<List<String>> rows;

  /// Relative widths, one per column; sent only when they match the columns.
  final List<double> widths;
  final bool compact;

  final Object? namesColumn;

  const TableBlock(super.id, {required this.columns, this.rows = const [], this.widths = const [], this.compact = false, this.namesColumn});

  @override
  String get kind => ReportBlockKinds.table;

  /// Every row trimmed or padded to the columns, as the server prints it.
  List<List<String>> get squaredRows => [
        for (final row in rows) [for (var i = 0; i < columns.length; i++) i < row.length ? row[i] : ''],
      ];

  @override
  Map<String, dynamic> toJson() => {
        'kind': kind,
        'columns': columns,
        'rows': squaredRows,
        if (widths.length == columns.length) 'widths': widths,
        'compact': compact,
      };

  @override
  TableBlock withId(int id) => TableBlock(id, columns: columns, rows: rows, widths: widths, compact: compact, namesColumn: namesColumn);

  /// Changing the columns drops [widths], which no longer match.
  TableBlock copyWith({List<String>? columns, List<List<String>>? rows, bool? compact}) => TableBlock(
        id,
        columns: columns ?? this.columns,
        rows: rows ?? this.rows,
        widths: columns == null || columns.length == this.columns.length ? widths : const [],
        compact: compact ?? this.compact,
        namesColumn: namesColumn,
      );

  @override
  List<Object?> get props => [id, columns, rows, widths, compact, namesColumn];
}

class ReportPair extends Equatable {
  final String label;
  final String value;

  const ReportPair({this.label = '', this.value = ''});

  factory ReportPair.fromJson(Map<String, dynamic> json) =>
      ReportPair(label: _text(json['label']), value: _text(json['value']));

  Map<String, dynamic> toJson() => {'label': label, 'value': value};

  @override
  List<Object?> get props => [label, value];
}

class KvBlock extends ReportBlock {
  final List<ReportPair> pairs;

  const KvBlock(super.id, {this.pairs = const []});

  @override
  String get kind => ReportBlockKinds.kv;

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'pairs': pairs.map((p) => p.toJson()).toList()};

  @override
  KvBlock withId(int id) => KvBlock(id, pairs: pairs);

  KvBlock copyWith({List<ReportPair>? pairs}) => KvBlock(id, pairs: pairs ?? this.pairs);

  @override
  List<Object?> get props => [id, pairs];
}

class ReportColumn extends Equatable {
  final String heading;
  final List<String> items;

  const ReportColumn({this.heading = '', this.items = const []});

  factory ReportColumn.fromJson(Map<String, dynamic> json) =>
      ReportColumn(heading: _text(json['heading']), items: _texts(json['items']));

  Map<String, dynamic> toJson() => {'heading': heading, 'items': items};

  ReportColumn copyWith({String? heading, List<String>? items}) =>
      ReportColumn(heading: heading ?? this.heading, items: items ?? this.items);

  @override
  List<Object?> get props => [heading, items];
}

class ColumnsBlock extends ReportBlock {
  /// Two or three, side by side.
  final List<ReportColumn> columns;

  const ColumnsBlock(super.id, {required this.columns});

  @override
  String get kind => ReportBlockKinds.columns;

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'columns': columns.map((c) => c.toJson()).toList()};

  @override
  ColumnsBlock withId(int id) => ColumnsBlock(id, columns: columns);

  ColumnsBlock copyWith({List<ReportColumn>? columns}) => ColumnsBlock(id, columns: columns ?? this.columns);

  @override
  List<Object?> get props => [id, columns];
}

class ImagesBlock extends ReportBlock {
  /// Storage paths, each also in the report's `images`.
  final List<String> items;

  /// Photos per row, 1–3.
  final int columns;

  const ImagesBlock(super.id, {this.items = const [], this.columns = 2});

  @override
  String get kind => ReportBlockKinds.images;

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'items': items, 'columns': columns};

  @override
  ImagesBlock withId(int id) => ImagesBlock(id, items: items, columns: columns);

  ImagesBlock copyWith({List<String>? items, int? columns}) =>
      ImagesBlock(id, items: items ?? this.items, columns: columns ?? this.columns);

  @override
  List<Object?> get props => [id, items, columns];
}

class ReportSeries extends Equatable {
  final String name;

  /// One per label; numbers ≥ 0.
  final List<double> values;

  const ReportSeries({this.name = '', this.values = const []});

  factory ReportSeries.fromJson(Map<String, dynamic> json) => ReportSeries(
        name: _text(json['name']),
        values: json['values'] is List
            ? (json['values'] as List).map((v) => (_number(v) ?? 0).clamp(0, double.infinity).toDouble()).toList()
            : const [],
      );

  Map<String, dynamic> toJson() => {'name': name, 'values': values};

  @override
  List<Object?> get props => [name, values];
}

class ChartBlock extends ReportBlock {
  final String title;
  final List<String> labels;
  final List<ReportSeries> series;
  final bool compact;

  const ChartBlock(super.id, {this.title = '', this.labels = const [], this.series = const [], this.compact = false});

  @override
  String get kind => ReportBlockKinds.chart;

  /// Each series' values trimmed or padded with 0 to the labels.
  @override
  Map<String, dynamic> toJson() => {
        'kind': kind,
        'chart': 'bar',
        'title': title,
        'labels': labels,
        'series': [
          for (final s in series)
            {
              'name': s.name,
              'values': [for (var i = 0; i < labels.length; i++) i < s.values.length ? s.values[i] : 0.0],
            },
        ],
        'compact': compact,
      };

  @override
  ChartBlock withId(int id) => ChartBlock(id, title: title, labels: labels, series: series, compact: compact);

  ChartBlock copyWith({String? title, List<String>? labels, List<ReportSeries>? series, bool? compact}) => ChartBlock(
        id,
        title: title ?? this.title,
        labels: labels ?? this.labels,
        series: series ?? this.series,
        compact: compact ?? this.compact,
      );

  @override
  List<Object?> get props => [id, title, labels, series, compact];
}

class QrBlock extends ReportBlock {
  /// https only.
  final String url;
  final String caption;

  const QrBlock(super.id, {this.url = '', this.caption = ''});

  @override
  String get kind => ReportBlockKinds.qr;

  @override
  Map<String, dynamic> toJson() => {'kind': kind, 'url': url, 'caption': caption};

  @override
  QrBlock withId(int id) => QrBlock(id, url: url, caption: caption);

  QrBlock copyWith({String? url, String? caption}) => QrBlock(id, url: url ?? this.url, caption: caption ?? this.caption);

  @override
  List<Object?> get props => [id, url, caption];
}

class PageBreakBlock extends ReportBlock {
  const PageBreakBlock(super.id);

  @override
  String get kind => ReportBlockKinds.pageBreak;

  @override
  Map<String, dynamic> toJson() => {'kind': kind};

  @override
  PageBreakBlock withId(int id) => PageBreakBlock(id);

  @override
  List<Object?> get props => [id];
}

/// A kind added on the server after this version: kept and sent back as it came.
class UnknownBlock extends ReportBlock {
  final Map<String, dynamic> raw;

  const UnknownBlock(super.id, this.raw);

  @override
  String get kind => raw['kind']?.toString() ?? '';

  @override
  Map<String, dynamic> toJson() => raw;

  @override
  UnknownBlock withId(int id) => UnknownBlock(id, raw);

  @override
  List<Object?> get props => [id, raw];
}

String _text(dynamic value) => value is String ? value : (value?.toString() ?? '');

List<String> _texts(dynamic value) => value is List ? value.map(_text).toList() : const [];

List<Map<String, dynamic>> _maps(dynamic value) =>
    value is List ? value.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList() : const [];

double? _number(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

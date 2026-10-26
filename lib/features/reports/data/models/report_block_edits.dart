/// Pure edits on report blocks, so the editor widgets stay simple and the
/// rules are tested once. Limits come from the catalogue.
library;

import 'package:moean/core/utils/formatters/localized_digits.dart';
import 'package:moean/features/reports/data/models/report_block.dart';

/// A list of lines: add, edit, remove, move. [newIndex] is the final position.
extension ReportLines on List<String> {
  List<String> addLine(String text, int max) => length >= max ? this : [...this, text.trim()];

  List<String> editLine(int index, String text) => [...this]..[index] = text.trim();

  List<String> removeLine(int index) => [...this]..removeAt(index);

  List<String> moveLine(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return this;
    final lines = [...this];
    lines.insert(newIndex, lines.removeAt(oldIndex));
    return lines;
  }
}

extension TableBlockEdits on TableBlock {
  TableBlock setColumns(List<String> headers) => copyWith(columns: headers.map((h) => h.trim()).toList());

  TableBlock addColumn(int max) => columns.length >= max
      ? this
      : copyWith(columns: [...columns, ''], rows: [for (final row in squaredRows) [...row, '']]);

  /// A table keeps at least one column.
  TableBlock removeColumn(int index) => columns.length <= 1
      ? this
      : copyWith(
          columns: [...columns]..removeAt(index),
          rows: [for (final row in squaredRows) [...row]..removeAt(index)],
        );

  TableBlock addRow(int max) => rows.length >= max ? this : copyWith(rows: [...squaredRows, List.filled(columns.length, '')]);

  TableBlock setRow(int index, List<String> cells) =>
      copyWith(rows: [...squaredRows]..[index] = cells.map((c) => c.trim()).toList());

  TableBlock removeRow(int index) => copyWith(rows: [...squaredRows]..removeAt(index));
}

extension KvBlockEdits on KvBlock {
  KvBlock addPair(String label, String value, int max) =>
      pairs.length >= max ? this : copyWith(pairs: [...pairs, ReportPair(label: label.trim(), value: value.trim())]);

  KvBlock setPair(int index, String label, String value) =>
      copyWith(pairs: [...pairs]..[index] = ReportPair(label: label.trim(), value: value.trim()));

  KvBlock removePair(int index) => copyWith(pairs: [...pairs]..removeAt(index));
}

extension ColumnsBlockEdits on ColumnsBlock {
  /// Two or three columns; going down drops the last one.
  ColumnsBlock setCount(int count) {
    final target = count.clamp(2, 3);
    if (target == columns.length) return this;
    return copyWith(
      columns: target > columns.length ? [...columns, const ReportColumn()] : columns.sublist(0, target),
    );
  }

  ColumnsBlock setColumn(int index, ReportColumn column) => copyWith(columns: [...columns]..[index] = column);
}

extension ImagesBlockEdits on ImagesBlock {
  ImagesBlock toggle(String path) =>
      copyWith(items: items.contains(path) ? (items.where((p) => p != path).toList()) : [...items, path]);
}

extension ChartBlockEdits on ChartBlock {
  /// New labels keep each series' values by position.
  ChartBlock setLabels(List<String> labels) => copyWith(labels: labels);

  ChartBlock addSeries(int max) => series.length >= max ? this : copyWith(series: [...series, const ReportSeries()]);

  /// [values] are the typed texts; anything that isn't a number ≥ 0 becomes 0.
  ChartBlock setSeries(int index, String name, List<String> values) => copyWith(
        series: [...series]
          ..[index] = ReportSeries(
            name: name.trim(),
            values: values
                .map((v) => (double.tryParse(latinDigits(v.trim()).replaceAll('٫', '.')) ?? 0).clamp(0, 1000000).toDouble())
                .toList(),
          ),
      );

  ChartBlock removeSeries(int index) => copyWith(series: [...series]..removeAt(index));
}

/// An https link with a host, as the server accepts for a QR block.
bool isHttpsUrl(String text) {
  final uri = Uri.tryParse(text.trim());
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
}

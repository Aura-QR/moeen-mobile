/// Models for `GET /tools/activities/plan`: the suggested grid the teacher
/// edits (DOCUMENTS_API.md § 6).
library;

abstract final class ActivitiesColumns {
  /// The week's national and international days; every non-holiday week has it.
  static const String occasion = 'occasion';
}

enum ActivitiesWeekType {
  teaching,
  exam,
  holiday;

  static ActivitiesWeekType fromJson(dynamic value) =>
      values.where((type) => type.name == value?.toString()).firstOrNull ?? teaching;
}

class ActivitiesColumnModel {
  final String key;
  final String label;

  const ActivitiesColumnModel({required this.key, required this.label});

  factory ActivitiesColumnModel.fromJson(Map<String, dynamic> json) => ActivitiesColumnModel(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
      );
}

/// One row: a teaching or exam week, or a holiday (no number, no cells).
class ActivitiesWeekModel {
  final int? week;
  final ActivitiesWeekType type;
  final String title;
  final String start;
  final String end;

  /// Can be null; the Gregorian dates are shown then.
  final String? startHijri;
  final String? endHijri;

  /// The suggestion per column key.
  final Map<String, String> cells;

  const ActivitiesWeekModel({
    this.week,
    required this.type,
    this.title = '',
    this.start = '',
    this.end = '',
    this.startHijri,
    this.endHijri,
    this.cells = const {},
  });

  factory ActivitiesWeekModel.fromJson(Map<String, dynamic> json) {
    final cells = json['cells'];
    return ActivitiesWeekModel(
      week: int.tryParse('${json['week']}'),
      type: ActivitiesWeekType.fromJson(json['type']),
      title: json['title']?.toString() ?? '',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      startHijri: json['start_hijri']?.toString(),
      endHijri: json['end_hijri']?.toString(),
      cells: cells is Map
          ? {for (final entry in cells.entries) entry.key.toString(): entry.value?.toString() ?? ''}
          : const {},
    );
  }

  bool get isHoliday => type == ActivitiesWeekType.holiday;

  /// «09-08-1448 – 13-08-1448», or null without both Hijri dates.
  String? get hijriRange => startHijri == null || endHijri == null ? null : '$startHijri – $endHijri';

  String get gregorianRange => start == end ? start : '$start – $end';
}

class ActivitiesGridModel {
  final int term;
  final String region;

  /// False while the region's dates are still checked against the Ministry's calendar.
  final bool regionVerified;

  /// The chosen domains in order, then [ActivitiesColumns.occasion].
  final List<ActivitiesColumnModel> columns;
  final List<ActivitiesWeekModel> weeks;

  const ActivitiesGridModel({
    required this.term,
    required this.region,
    this.regionVerified = true,
    this.columns = const [],
    this.weeks = const [],
  });

  factory ActivitiesGridModel.fromJson(Map<String, dynamic> json) {
    final columns = json['columns'];
    final weeks = json['weeks'];
    return ActivitiesGridModel(
      term: int.tryParse('${json['term']}') ?? 1,
      region: json['region']?.toString() ?? '',
      regionVerified: json['region_verified'] != false,
      columns: columns is List
          ? columns.whereType<Map<String, dynamic>>().map(ActivitiesColumnModel.fromJson).toList()
          : const [],
      weeks: weeks is List
          ? weeks.whereType<Map<String, dynamic>>().map(ActivitiesWeekModel.fromJson).toList()
          : const [],
    );
  }

  /// The columns a week can edit: every column for a teaching week, only the
  /// occasions for an exam week, none for a holiday.
  List<ActivitiesColumnModel> columnsOf(ActivitiesWeekModel week) => switch (week.type) {
        ActivitiesWeekType.teaching => columns,
        ActivitiesWeekType.exam => columns.where((column) => column.key == ActivitiesColumns.occasion).toList(),
        ActivitiesWeekType.holiday => const [],
      };

  ActivitiesWeekModel? weekNumber(int week) => weeks.where((row) => row.week == week).firstOrNull;
}

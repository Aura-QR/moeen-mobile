import 'package:moean/features/documents/data/models/document_theme.dart';

/// The form sent as `input` for `type: activities_plan` (DOCUMENTS_API.md § 6).
/// `input` is the source of truth when reopening.
class ActivitiesPlanInput {
  final String stage;

  /// Domain keys in column order.
  final List<String> domains;
  final int term;

  /// `general` or `western`; null uses the teacher's `region_calendar`.
  final String? region;
  final String activityLeader;
  final String academicYear;

  /// Only the cells the teacher changed: week number → column key → text.
  /// An empty text means the teacher emptied the cell.
  final Map<int, Map<String, String>> cells;
  final String notes;
  final DocumentTheme theme;
  final Map<String, String> header;
  final List<String> images;

  /// Fields this app doesn't edit, kept so saving from the phone doesn't drop them.
  final Map<String, dynamic> extra;

  static const String general = 'general';
  static const String western = 'western';

  const ActivitiesPlanInput({
    required this.stage,
    required this.domains,
    required this.term,
    this.region,
    this.activityLeader = '',
    this.academicYear = '',
    this.cells = const {},
    this.notes = '',
    this.theme = DocumentTheme.teal,
    this.header = const {},
    this.images = const [],
    this.extra = const {},
  });

  static const _ownKeys = {
    'stage', 'domains', 'term', 'region', 'activity_leader', 'academic_year', 'cells', 'notes', 'theme', 'header',
    'images',
  };

  factory ActivitiesPlanInput.fromJson(Map<String, dynamic> json) {
    final domains = json['domains'];
    final cells = json['cells'];
    final header = json['header'];
    final images = json['images'];
    final region = json['region']?.toString();
    return ActivitiesPlanInput(
      stage: json['stage']?.toString() ?? '',
      domains: domains is List ? domains.map((e) => e.toString()).toList() : const [],
      term: int.tryParse('${json['term']}') ?? 1,
      region: region == null || region.isEmpty ? null : region,
      activityLeader: _text(json['activity_leader']),
      academicYear: _text(json['academic_year']),
      cells: cells is Map
          ? {
              for (final week in cells.entries)
                if (int.tryParse('${week.key}') case final int number when week.value is Map)
                  number: {
                    for (final cell in (week.value as Map).entries) cell.key.toString(): cell.value?.toString() ?? '',
                  },
            }
          : const {},
      notes: _text(json['notes']),
      theme: DocumentTheme.fromJson(json['theme']),
      header: header is Map
          ? {
              for (final entry in header.entries)
                if (entry.value != null) entry.key.toString(): entry.value.toString(),
            }
          : const {},
      images: images is List ? images.map((e) => e.toString()).toList() : const [],
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  /// Empty fields are left out.
  Map<String, dynamic> toJson() => {
        ...extra,
        'stage': stage,
        'domains': domains,
        'term': term,
        'region': ?region,
        if (activityLeader.isNotEmpty) 'activity_leader': activityLeader,
        if (academicYear.isNotEmpty) 'academic_year': academicYear,
        if (cells.isNotEmpty)
          'cells': {
            for (final week in cells.entries)
              if (week.value.isNotEmpty) '${week.key}': week.value,
          },
        if (notes.isNotEmpty) 'notes': notes,
        'theme': theme.name,
        if (header.isNotEmpty) 'header': header,
        'images': images,
      };

  static String _text(dynamic value) => value?.toString().trim() ?? '';
}

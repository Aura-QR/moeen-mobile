import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';

/// The form sent as `input` for `remedial_plan` and `enrichment_plan`
/// (DOCUMENTS_API.md § 8). `input` is the source of truth when reopening.
class PlanFormInput {
  /// `linked` or `general` for the remedial plan; null for the enrichment
  /// plan, whose type follows from [lessonIds].
  final String? planType;
  final List<int> lessonIds;
  final String subject;
  final String grade;
  final String className;
  final DateTime? date;
  final String period;

  /// The «فصولي» class the names came from, only to reopen the picker.
  final int? classId;
  final List<String> students;

  /// Only the ticked lines, keyed by section.
  final Map<String, List<String>> sections;
  final String improvement;
  final List<String> targetGroups;
  final String notes;
  final DocumentTheme theme;
  final Map<String, String> header;
  final List<String> images;

  /// Fields this app doesn't edit (e.g. `academic_year`, `date_hijri`),
  /// kept so saving from the phone doesn't drop them.
  final Map<String, dynamic> extra;

  static const String linked = 'linked';
  static const String general = 'general';

  const PlanFormInput({
    this.planType,
    this.lessonIds = const [],
    this.subject = '',
    this.grade = '',
    this.className = '',
    this.date,
    this.period = '',
    this.classId,
    this.students = const [],
    this.sections = const {},
    this.improvement = '',
    this.targetGroups = const [],
    this.notes = '',
    this.theme = DocumentTheme.teal,
    this.header = const {},
    this.images = const [],
    this.extra = const {},
  });

  static const _ownKeys = {
    'plan_type', 'lesson_ids', 'subject', 'grade', 'class_name', 'date', 'period', 'class_id', 'students',
    'improvement', 'target_groups', 'notes', 'theme', 'header', 'images',
  };

  /// [sectionKeys] are the tool's section keys, read as ticked lines.
  factory PlanFormInput.fromJson(Map<String, dynamic> json, {required Iterable<String> sectionKeys}) {
    final keys = sectionKeys.toSet();
    final header = json['header'];
    return PlanFormInput(
      planType: json['plan_type']?.toString(),
      lessonIds: [
        for (final id in _list(json['lesson_ids']))
          if (int.tryParse(id.toString()) case final int value) value,
      ],
      subject: _text(json['subject']),
      grade: _text(json['grade']),
      className: _text(json['class_name']),
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      period: _text(json['period']),
      classId: int.tryParse(json['class_id']?.toString() ?? ''),
      students: _strings(json['students']),
      sections: {for (final key in keys) key: _strings(json[key])},
      improvement: _text(json['improvement']),
      targetGroups: _strings(json['target_groups']),
      notes: _text(json['notes']),
      theme: DocumentTheme.fromJson(json['theme']),
      header: header is Map
          ? {
              for (final entry in header.entries)
                if (entry.value != null) entry.key.toString(): entry.value.toString(),
            }
          : const {},
      images: _strings(json['images']),
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key) && !keys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  /// Empty fields are left out; empty sections print nothing.
  Map<String, dynamic> toJson() {
    final date = this.date;
    return {
      ...extra,
      'plan_type': ?planType,
      if (lessonIds.isNotEmpty) 'lesson_ids': lessonIds,
      if (subject.isNotEmpty) 'subject': subject,
      if (grade.isNotEmpty) 'grade': grade,
      if (className.isNotEmpty) 'class_name': className,
      if (date != null) 'date': isoDate(date),
      if (period.isNotEmpty) 'period': period,
      'class_id': ?classId,
      'students': students,
      for (final entry in sections.entries) entry.key: entry.value,
      if (improvement.isNotEmpty) 'improvement': improvement,
      if (targetGroups.isNotEmpty) 'target_groups': targetGroups,
      if (notes.isNotEmpty) 'notes': notes,
      'theme': theme.name,
      if (header.isNotEmpty) 'header': header,
      'images': images,
    };
  }

  static List<dynamic> _list(dynamic value) => value is List ? value : const [];

  static List<String> _strings(dynamic value) =>
      _list(value).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();

  static String _text(dynamic value) => value?.toString().trim() ?? '';
}

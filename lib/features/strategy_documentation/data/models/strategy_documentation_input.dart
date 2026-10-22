import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_models.dart';

/// The form sent as `input` for `type: strategy_documentation`
/// (DOCUMENTS_API.md § 5). `input` is the source of truth when reopening.
class StrategyDocumentationInput {
  final String strategyKey;
  final String subject;
  final String grade;
  final int? lessonId;
  final String lessonTitle;
  final String className;
  final int? studentsCount;
  final DateTime? executionDate;
  final String definition;
  final Map<StrategyListSection, List<String>> lists;
  final String notes;
  final DocumentTheme theme;
  final Map<String, String> header;
  final List<String> images;

  /// Fields this app doesn't edit (e.g. `academic_year` set on the website),
  /// kept so saving from the phone doesn't drop them.
  final Map<String, dynamic> extra;

  const StrategyDocumentationInput({
    required this.strategyKey,
    this.subject = '',
    this.grade = '',
    this.lessonId,
    this.lessonTitle = '',
    this.className = '',
    this.studentsCount,
    this.executionDate,
    this.definition = '',
    this.lists = const {},
    this.notes = '',
    this.theme = DocumentTheme.teal,
    this.header = const {},
    this.images = const [],
    this.extra = const {},
  });

  static const _ownKeys = {
    'strategy_key', 'subject', 'grade', 'lesson_id', 'lesson_title', 'class_name', 'students_count',
    'execution_date', 'content', 'notes', 'theme', 'header', 'images',
  };

  factory StrategyDocumentationInput.fromJson(Map<String, dynamic> json) {
    final content = json['content'] is Map<String, dynamic> ? json['content'] as Map<String, dynamic> : const {};
    final header = json['header'];
    final images = json['images'];
    return StrategyDocumentationInput(
      strategyKey: json['strategy_key']?.toString() ?? '',
      subject: _text(json['subject']),
      grade: _text(json['grade']),
      lessonId: int.tryParse(json['lesson_id']?.toString() ?? ''),
      lessonTitle: _text(json['lesson_title']),
      className: _text(json['class_name']),
      studentsCount: int.tryParse(json['students_count']?.toString() ?? ''),
      executionDate: DateTime.tryParse(json['execution_date']?.toString() ?? ''),
      definition: _text(content['definition']),
      lists: {
        for (final section in StrategyListSection.values)
          if (content[section.jsonKey] is List)
            section: (content[section.jsonKey] as List).map((e) => e.toString()).toList(),
      },
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

  /// Empty fields are left out; empty `content.*` falls back to the catalogue.
  Map<String, dynamic> toJson() {
    final date = executionDate;
    return {
      ...extra,
      'strategy_key': strategyKey,
      if (subject.isNotEmpty) 'subject': subject,
      if (grade.isNotEmpty) 'grade': grade,
      'lesson_id': ?lessonId,
      if (lessonTitle.isNotEmpty) 'lesson_title': lessonTitle,
      if (className.isNotEmpty) 'class_name': className,
      'students_count': ?studentsCount,
      if (date != null) 'execution_date': isoDate(date),
      'content': {
        if (definition.isNotEmpty) 'definition': definition,
        for (final entry in lists.entries)
          if (entry.value.isNotEmpty) entry.key.jsonKey: entry.value,
      },
      if (notes.isNotEmpty) 'notes': notes,
      'theme': theme.name,
      if (header.isNotEmpty) 'header': header,
      'images': images,
    };
  }

  static String _text(dynamic value) => value?.toString().trim() ?? '';
}

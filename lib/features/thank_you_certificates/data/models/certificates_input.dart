import 'package:moean/core/utils/formatters/iso_date.dart';

/// The form sent as `input` for `type: certificates` (DOCUMENTS_API.md § 10).
/// `input` is the source of truth when reopening.
class CertificatesInput {
  /// One certificate per name, in this order.
  final List<String> names;

  /// The «فصولي» class the names came from, only to reopen the picker.
  final int? classId;
  final String reason;
  final String design;

  /// `male` or `female`; empty uses the teacher's `gender_form`.
  final String audience;

  /// Empty uses the reason's default title and text.
  final String title;
  final String text;
  final DateTime? date;
  final Map<String, String> header;

  /// Fields this app doesn't edit (e.g. `date_hijri`), kept so saving from
  /// the phone doesn't drop them.
  final Map<String, dynamic> extra;

  /// Where the student's name goes in [text].
  static const String namePlaceholder = '{name}';

  const CertificatesInput({
    required this.names,
    this.classId,
    required this.reason,
    required this.design,
    this.audience = '',
    this.title = '',
    this.text = '',
    this.date,
    this.header = const {},
    this.extra = const {},
  });

  static const _ownKeys = {'names', 'class_id', 'reason', 'design', 'audience', 'title', 'text', 'date', 'header'};

  /// The same certificate for other names, e.g. one name for «معاينة».
  CertificatesInput withNames(List<String> names) => CertificatesInput(
    names: names,
    classId: classId,
    reason: reason,
    design: design,
    audience: audience,
    title: title,
    text: text,
    date: date,
    header: header,
    extra: extra,
  );

  factory CertificatesInput.fromJson(Map<String, dynamic> json) {
    final names = json['names'];
    final header = json['header'];
    return CertificatesInput(
      names: names is List
          ? names.map((name) => name.toString()).where((name) => name.trim().isNotEmpty).toList()
          : const [],
      classId: int.tryParse('${json['class_id']}'),
      reason: _text(json['reason']),
      design: _text(json['design']),
      audience: _text(json['audience']),
      title: _text(json['title']),
      text: _text(json['text']),
      date: DateTime.tryParse(_text(json['date'])),
      header: header is Map
          ? {
              for (final entry in header.entries)
                if (entry.value != null) entry.key.toString(): entry.value.toString(),
            }
          : const {},
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  /// Empty fields are left out, so the backend uses its defaults.
  Map<String, dynamic> toJson() => {
    ...extra,
    'names': names,
    'class_id': ?classId,
    'reason': reason,
    'design': design,
    if (audience.isNotEmpty) 'audience': audience,
    if (title.isNotEmpty) 'title': title,
    if (text.isNotEmpty) 'text': text,
    if (date != null) 'date': isoDate(date!),
    if (header.isNotEmpty) 'header': header,
  };

  static String _text(dynamic value) => value?.toString().trim() ?? '';
}

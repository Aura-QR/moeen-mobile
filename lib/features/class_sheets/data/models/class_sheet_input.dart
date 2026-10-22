import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/class_sheets/data/models/class_sheet_column.dart';

/// The form sent as `input` for `type: class_sheet` (CLASS_SHEETS_API.md).
/// `input` is the source of truth when reopening or previewing.
class ClassSheetInput {
  final String kind;
  final String title;
  final String className;
  final int? classId;
  final String subject;
  final String grade;
  final String term;
  final List<String> students;
  final int emptyRows;
  final bool useEmptyRows;
  final List<ClassSheetColumn> columns;
  final DateTime? startDate;
  final int weeks;
  final DateTime? date;
  final Map<String, String> header;
  final Map<String, dynamic> extra;

  const ClassSheetInput({
    required this.kind,
    this.title = '',
    this.className = '',
    this.classId,
    this.subject = '',
    this.grade = '',
    this.term = '',
    this.students = const [],
    this.emptyRows = 30,
    this.useEmptyRows = false,
    this.columns = const [],
    this.startDate,
    this.weeks = 2,
    this.date,
    this.header = const {},
    this.extra = const {},
  });

  ClassSheetInput copyWith({
    String? kind,
    String? title,
    String? className,
    int? classId,
    bool clearClassId = false,
    String? subject,
    String? grade,
    String? term,
    List<String>? students,
    int? emptyRows,
    bool? useEmptyRows,
    List<ClassSheetColumn>? columns,
    DateTime? startDate,
    int? weeks,
    DateTime? date,
    Map<String, String>? header,
    Map<String, dynamic>? extra,
  }) =>
      ClassSheetInput(
        kind: kind ?? this.kind,
        title: title ?? this.title,
        className: className ?? this.className,
        classId: clearClassId ? null : (classId ?? this.classId),
        subject: subject ?? this.subject,
        grade: grade ?? this.grade,
        term: term ?? this.term,
        students: students ?? this.students,
        emptyRows: emptyRows ?? this.emptyRows,
        useEmptyRows: useEmptyRows ?? this.useEmptyRows,
        columns: columns ?? this.columns,
        startDate: startDate ?? this.startDate,
        weeks: weeks ?? this.weeks,
        date: date ?? this.date,
        header: header ?? this.header,
        extra: extra ?? this.extra,
      );

  static const _ownKeys = {
    'kind',
    'title',
    'class_name',
    'class_id',
    'subject',
    'grade',
    'term',
    'students',
    'empty_rows',
    'columns',
    'start_date',
    'weeks',
    'date',
    'header',
  };

  factory ClassSheetInput.fromJson(Map<String, dynamic> json) {
    final studentsRaw = json['students'];
    final columnsRaw = json['columns'];
    final headerRaw = json['header'];
    final emptyRows = int.tryParse('${json['empty_rows']}') ?? 30;
    final studentsList = studentsRaw is List
        ? studentsRaw.map((s) => s.toString().trim()).where((s) => s.isNotEmpty).toList()
        : <String>[];

    return ClassSheetInput(
      kind: json['kind']?.toString() ?? 'grades',
      title: json['title']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      classId: int.tryParse('${json['class_id']}'),
      subject: json['subject']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      term: json['term']?.toString() ?? '',
      students: studentsList,
      emptyRows: emptyRows,
      useEmptyRows: studentsList.isEmpty && json['empty_rows'] != null,
      columns: columnsRaw is List
          ? columnsRaw.whereType<Map<String, dynamic>>().map(ClassSheetColumn.fromJson).toList()
          : const [],
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? ''),
      weeks: int.tryParse('${json['weeks']}') ?? 2,
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      header: headerRaw is Map
          ? {
              for (final entry in headerRaw.entries)
                if (entry.value != null) entry.key.toString(): entry.value.toString(),
            }
          : const {},
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  Map<String, dynamic> toJson() => {
        ...extra,
        'kind': kind,
        if (title.isNotEmpty) 'title': title,
        if (className.isNotEmpty) 'class_name': className,
        if (classId != null) 'class_id': classId,
        if (subject.isNotEmpty) 'subject': subject,
        if (grade.isNotEmpty) 'grade': grade,
        if (term.isNotEmpty) 'term': term,
        if (useEmptyRows)
          'empty_rows': emptyRows
        else ...{
          'students': students,
          if (students.isEmpty) 'empty_rows': emptyRows,
        },
        if (columns.isNotEmpty) 'columns': columns.map((col) => col.toJson()).toList(),
        if (startDate != null) 'start_date': isoDate(startDate!),
        if (kind == 'attendance') 'weeks': weeks,
        if (date != null) 'date': isoDate(date!),
        if (header.isNotEmpty) 'header': header,
      };
}

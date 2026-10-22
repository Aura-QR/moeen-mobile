import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/grade_analysis/data/models/grade_options_model.dart';

/// One row of a class. A null [grade] with a name is «غائب».
class GradeStudentInput {
  final String name;
  final double? grade;

  const GradeStudentInput({this.name = '', this.grade});

  factory GradeStudentInput.fromJson(Map<String, dynamic> json) =>
      GradeStudentInput(name: json['name']?.toString().trim() ?? '', grade: double.tryParse('${json['grade']}'));

  Map<String, dynamic> toJson() => {'name': name, 'grade': grade};
}

class GradeClassInput {
  final String name;

  /// The «فصولي» class the names came from, only to reopen the picker.
  final int? classId;
  final List<GradeStudentInput> students;

  const GradeClassInput({this.name = '', this.classId, this.students = const []});

  factory GradeClassInput.fromJson(Map<String, dynamic> json) {
    final students = json['students'];
    return GradeClassInput(
      name: json['name']?.toString().trim() ?? '',
      classId: int.tryParse('${json['class_id']}'),
      students: students is List
          ? students.whereType<Map<String, dynamic>>().map(GradeStudentInput.fromJson).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'class_id': ?classId,
    'students': students.map((student) => student.toJson()).toList(),
  };
}

/// The form sent as `input` for `type: grade_analysis`, and to
/// `POST /tools/grades/analyze` (GRADE_ANALYSIS_API.md § 2).
class GradeAnalysisInput {
  final String reportType;
  final String subject;
  final String grade;
  final String testName;
  final DateTime? date;
  final double totalMark;

  /// Null uses `pass_percent` of the total.
  final double? passMark;

  /// Empty uses the default levels.
  final List<GradeBand> bands;
  final List<GradeClassInput> classes;

  /// Only the lines the teacher kept.
  final List<String> recommendations;
  final String notes;
  final DocumentTheme theme;
  final Map<String, String> header;
  final List<String> images;

  /// Fields this app doesn't edit (e.g. `academic_year`, `date_hijri`),
  /// kept so saving from the phone doesn't drop them.
  final Map<String, dynamic> extra;

  const GradeAnalysisInput({
    required this.reportType,
    this.subject = '',
    this.grade = '',
    this.testName = '',
    this.date,
    required this.totalMark,
    this.passMark,
    this.bands = const [],
    this.classes = const [],
    this.recommendations = const [],
    this.notes = '',
    this.theme = DocumentTheme.teal,
    this.header = const {},
    this.images = const [],
    this.extra = const {},
  });

  static const _ownKeys = {
    'report_type',
    'subject',
    'grade',
    'test_name',
    'date',
    'total_mark',
    'pass_mark',
    'bands',
    'classes',
    'recommendations',
    'notes',
    'theme',
    'header',
    'images',
  };

  factory GradeAnalysisInput.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) {
      final value = json[key];
      return value is List ? value.whereType<Map<String, dynamic>>().map(parse).toList() : <T>[];
    }

    final recommendations = json['recommendations'];
    final header = json['header'];
    final images = json['images'];
    return GradeAnalysisInput(
      reportType: GradeReportTypes.all.contains(json['report_type'])
          ? json['report_type'] as String
          : GradeReportTypes.quick,
      subject: _text(json['subject']),
      grade: _text(json['grade']),
      testName: _text(json['test_name']),
      date: DateTime.tryParse(_text(json['date'])),
      totalMark: double.tryParse('${json['total_mark']}') ?? 0,
      passMark: double.tryParse('${json['pass_mark']}'),
      bands: list('bands', GradeBand.fromJson),
      classes: list('classes', GradeClassInput.fromJson),
      recommendations: recommendations is List
          ? recommendations.map((line) => line.toString().trim()).where((line) => line.isNotEmpty).toList()
          : const [],
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

  /// Empty fields are left out, so the backend uses its defaults.
  Map<String, dynamic> toJson() => {
    ...extra,
    'report_type': reportType,
    if (subject.isNotEmpty) 'subject': subject,
    if (grade.isNotEmpty) 'grade': grade,
    if (testName.isNotEmpty) 'test_name': testName,
    if (date != null) 'date': isoDate(date!),
    'total_mark': totalMark,
    'pass_mark': ?passMark,
    if (bands.isNotEmpty) 'bands': bands.map((band) => band.toJson()).toList(),
    'classes': classes.map((schoolClass) => schoolClass.toJson()).toList(),
    if (recommendations.isNotEmpty) 'recommendations': recommendations,
    if (notes.isNotEmpty) 'notes': notes,
    'theme': theme.name,
    if (header.isNotEmpty) 'header': header,
    'images': images,
  };

  static String _text(dynamic value) => value?.toString().trim() ?? '';
}

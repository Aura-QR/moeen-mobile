/// Models for `/classes` (CLASSES_API.md).
library;

/// The API's limits for «فصولي».
abstract final class ClassLimits {
  static const int maxClasses = 40;
  static const int maxStudents = 80;
  static const int maxClassNameLength = 60;
  static const int maxStudentNameLength = 120;
  static const int maxFieldLength = 120;

  /// `/classes/import` accepts files up to 2 MB.
  static const int maxImportBytes = 2 * 1024 * 1024;
}

/// A saved class. [students] is empty on list items; use [studentsCount].
class SchoolClassModel {
  final int? id;
  final String name;
  final String grade;
  final String subject;
  final int studentsCount;
  final List<String> students;
  final DateTime? updatedAt;

  const SchoolClassModel({
    this.id,
    required this.name,
    this.grade = '',
    this.subject = '',
    this.studentsCount = 0,
    this.students = const [],
    this.updatedAt,
  });

  factory SchoolClassModel.fromJson(Map<String, dynamic> json) {
    final students = json['students'];
    final names = students is List
        ? students
            .map((student) => student is Map ? student['name']?.toString() ?? '' : student.toString())
            .where((name) => name.isNotEmpty)
            .toList()
        : const <String>[];
    return SchoolClassModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: json['name']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      studentsCount: int.tryParse('${json['students_count']}') ?? names.length,
      students: names,
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  /// The body for `POST` and `PUT`: `students` replaces the whole list, in order.
  Map<String, dynamic> toJson() => {
        'name': name,
        'grade': grade.isEmpty ? null : grade,
        'subject': subject.isEmpty ? null : subject,
        'students': students,
      };
}

enum ClassStatus {
  activity,
  notPrepared,
  prepared,
  waiting,
}

class DayModel {
  final String nameKey;
  final String date;
  final int dayOfWeek;

  const DayModel({
    required this.nameKey,
    required this.date,
    required this.dayOfWeek,
  });
}

class ClassModel {
  final String id;
  final int periodNumber;
  final String? lessonTitle;
  final String classroomId;
  final ClassStatus status;
  final int dayOfWeek;
  final String realSchoolId;
  final String timeTaleId;
  final int subjectId;
  final int lessonId;

  const ClassModel({
    required this.id,
    required this.periodNumber,
    this.lessonTitle,
    required this.classroomId,
    required this.status,
    required this.dayOfWeek,
    this.realSchoolId = '',
    this.timeTaleId = '',
    this.subjectId = 0,
    this.lessonId = 0,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    final lessonTitle = json['lesson_title'] as String?;
    return ClassModel(
      id: json['id'].toString(),
      periodNumber: json['period_number'] as int? ?? 0,
      lessonTitle: lessonTitle,
      classroomId: json['classroom_id'] as String? ?? '',
      status:
          lessonTitle != null ? ClassStatus.prepared : ClassStatus.notPrepared,
      dayOfWeek: json['day_of_week'] as int? ?? 1,
      realSchoolId: json['real_school_id'] as String? ?? '',
      timeTaleId: json['time_table_id'] as String? ?? '',
      subjectId: int.tryParse(json['subject_id']?.toString() ?? '') ?? 0,
      lessonId: int.tryParse(json['lesson_id']?.toString() ?? '') ?? 
                int.tryParse(json['lesson_madrasati_id']?.toString() ?? '') ?? 0,
    );
  }

  /// Returns a translation key like 'class_1', 'class_2', etc.
  String get periodKey => 'class_$periodNumber';
}

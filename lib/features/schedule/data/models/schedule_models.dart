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
  final String time;
  final String date;

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
    this.time = '',
    this.date = '',
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    final lessonTitle = json['subject_name'] as String? ?? json['lesson_title'] as String?;
    
    ClassStatus parsedStatus = ClassStatus.notPrepared;
    final statusStr = json['status'] as String?;
    if (statusStr == 'تم إعداد الدرس') parsedStatus = ClassStatus.prepared;
    else if (statusStr == 'نشاط') parsedStatus = ClassStatus.activity;
    else if (statusStr == 'بإعداد الدرس' || statusStr == 'بانتظار إعداد الدرس') parsedStatus = ClassStatus.waiting;
    else if (lessonTitle != null && statusStr == null) parsedStatus = ClassStatus.prepared;

    int pNum = json['period_number'] as int? ?? 0;
    if (pNum == 0) {
      final periodStr = json['period'] as String? ?? '';
      if (periodStr.contains('الأولى')) pNum = 1;
      else if (periodStr.contains('الثانية')) pNum = 2;
      else if (periodStr.contains('الثالثة')) pNum = 3;
      else if (periodStr.contains('الرابعة')) pNum = 4;
      else if (periodStr.contains('الخامسة')) pNum = 5;
      else if (periodStr.contains('السادسة')) pNum = 6;
      else if (periodStr.contains('السابعة')) pNum = 7;
    }

    int dNum = json['day_of_week'] as int? ?? 1;
    final dayStr = json['day'] as String?;
    if (dayStr != null) {
      if (dayStr == 'الأحد') dNum = 1;
      else if (dayStr == 'الاثنين') dNum = 2;
      else if (dayStr == 'الثلاثاء') dNum = 3;
      else if (dayStr == 'الأربعاء') dNum = 4;
      else if (dayStr == 'الخميس') dNum = 5;
    }

    return ClassModel(
      id: json['lesson_id']?.toString() ?? json['id']?.toString() ?? '',
      periodNumber: pNum,
      lessonTitle: lessonTitle,
      classroomId: json['grade'] as String? ?? json['classroom_id'] as String? ?? '',
      status: parsedStatus,
      dayOfWeek: dNum,
      realSchoolId: json['real_school_id'] as String? ?? '',
      timeTaleId: json['time_table_id'] as String? ?? '',
      subjectId: int.tryParse(json['subject_id']?.toString() ?? '') ?? 0,
      lessonId: int.tryParse(json['lesson_id']?.toString() ?? '') ?? 
                int.tryParse(json['lesson_madrasati_id']?.toString() ?? '') ?? 0,
      time: json['time'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  /// Returns a translation key like 'class_1', 'class_2', etc.
  String get periodKey => 'class_$periodNumber';
}

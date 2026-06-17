enum ClassStatus {
  activity,
  notPrepared,
  prepared,
  waiting,
}

class DayModel {
  final String nameKey;
  final String date;

  DayModel({required this.nameKey, required this.date});
}

class ClassModel {
  final String id;
  final String time;
  final String numberKey;
  final String subjectKey;
  final String gradeKey;
  final ClassStatus status;
  final String? lessonTitle;

  ClassModel({
    required this.id,
    required this.time,
    required this.numberKey,
    required this.subjectKey,
    required this.gradeKey,
    required this.status,
    this.lessonTitle,
  });
}

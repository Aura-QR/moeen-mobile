/// A subject in the lesson picker, with the grade it belongs to.
class LessonPickerSubjectModel {
  final int subjectId;
  final String subjectName;
  final String gradeName;

  const LessonPickerSubjectModel({
    required this.subjectId,
    required this.subjectName,
    required this.gradeName,
  });

  bool matches(String query) {
    final q = query.trim();
    return q.isEmpty || subjectName.contains(q) || gradeName.contains(q);
  }
}

/// The lesson the teacher picked from the curriculum: sent as `lesson_id`
/// and `lesson_title`, and used to fill «المادة» and «الصف».
class PickedLessonModel {
  final int lessonId;
  final String lessonTitle;
  final String subjectName;
  final String gradeName;

  const PickedLessonModel({
    required this.lessonId,
    required this.lessonTitle,
    required this.subjectName,
    required this.gradeName,
  });
}

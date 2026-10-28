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

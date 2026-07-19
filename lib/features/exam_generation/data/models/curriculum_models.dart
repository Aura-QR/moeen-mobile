class CurriculumStageModel {
  final int id;
  final String name;
  final List<CurriculumGradeModel> grades;

  CurriculumStageModel({required this.id, required this.name, required this.grades});

  factory CurriculumStageModel.fromJson(Map<String, dynamic> json) {
    return CurriculumStageModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      grades: (json['grades'] as List?)?.map((e) => CurriculumGradeModel.fromJson(e)).toList() ?? [],
    );
  }
}

class CurriculumGradeModel {
  final int id;
  final String name;
  final String? track;
  final List<CurriculumSubjectModel> subjects;

  CurriculumGradeModel({required this.id, required this.name, this.track, required this.subjects});

  factory CurriculumGradeModel.fromJson(Map<String, dynamic> json) {
    return CurriculumGradeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      track: json['track']?.toString(),
      subjects: (json['subjects'] as List?)?.map((e) => CurriculumSubjectModel.fromJson(e)).toList() ?? [],
    );
  }
}

class CurriculumSubjectModel {
  final int id;
  final String name;

  CurriculumSubjectModel({required this.id, required this.name});

  factory CurriculumSubjectModel.fromJson(Map<String, dynamic> json) {
    return CurriculumSubjectModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class SubjectDetailsModel {
  final int subjectId;
  final String subjectName;
  final List<CurriculumChapterModel> chapters;

  SubjectDetailsModel({required this.subjectId, required this.subjectName, required this.chapters});

  factory SubjectDetailsModel.fromJson(Map<String, dynamic> json) {
    return SubjectDetailsModel(
      subjectId: json['subject_id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      chapters: (json['chapters'] as List?)?.map((e) => CurriculumChapterModel.fromJson(e)).toList() ?? [],
    );
  }
}

class CurriculumChapterModel {
  final int chapterId;
  final String title;
  final String? unitId;
  final String? unitName;
  final String semester;
  final List<CurriculumLessonModel> lessons;

  CurriculumChapterModel({
    required this.chapterId,
    required this.title,
    this.unitId,
    this.unitName,
    required this.semester,
    required this.lessons,
  });

  factory CurriculumChapterModel.fromJson(Map<String, dynamic> json) {
    return CurriculumChapterModel(
      chapterId: json['chapter_id'] ?? 0,
      title: json['title'] ?? '',
      unitId: json['unit_id']?.toString(),
      unitName: json['unit_name']?.toString(),
      semester: json['semester']?.toString() ?? '1',
      lessons: (json['lessons'] as List?)?.map((e) => CurriculumLessonModel.fromJson(e)).toList() ?? [],
    );
  }
}

class CurriculumLessonModel {
  final int id;
  final String title;
  final int orderIndex;
  final String semester;
  final int? sourceLessonId;
  final int? lessonApiId;

  CurriculumLessonModel({
    required this.id,
    required this.title,
    required this.orderIndex,
    required this.semester,
    this.sourceLessonId,
    this.lessonApiId,
  });

  factory CurriculumLessonModel.fromJson(Map<String, dynamic> json) {
    return CurriculumLessonModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      orderIndex: json['order_index'] ?? 0,
      semester: json['semester']?.toString() ?? '1',
      sourceLessonId: json['source_lesson_id'],
      lessonApiId: json['lesson_api_id'],
    );
  }
}

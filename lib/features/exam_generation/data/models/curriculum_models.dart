class SubjectGroupModel {
  final String name;
  final String title;
  final String? titleAr;
  final List<int> subjectIds;
  final int? lessonCount;
  final List<UnitModel> units;

  SubjectGroupModel({
    required this.name,
    required this.title,
    this.titleAr,
    this.subjectIds = const [],
    this.lessonCount,
    required this.units,
  });

  factory SubjectGroupModel.fromJson(Map<String, dynamic> json) {
    return SubjectGroupModel(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['title_ar'],
      subjectIds: (json['subject_ids'] as List?)?.map((e) => e as int).toList() ?? [],
      lessonCount: json['lesson_count'],
      units: (json['units'] as List?)
              ?.map((e) => UnitModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UnitModel {
  final int subjectId;
  final String name;
  final String title;
  final String? titleAr;
  final String? gradeLevel;
  final int? lessonCount;
  final String? mappingConfidence;

  UnitModel({
    required this.subjectId,
    required this.name,
    required this.title,
    this.titleAr,
    this.gradeLevel,
    this.lessonCount,
    this.mappingConfidence,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      subjectId: json['subject_id'] ?? 0,
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['title_ar'],
      gradeLevel: json['grade_level']?.toString(),
      lessonCount: json['lesson_count'],
      mappingConfidence: json['mapping_confidence']?.toString(),
    );
  }
}

class CurriculumLessonModel {
  final int id;
  final String name;

  CurriculumLessonModel({
    required this.id,
    required this.name,
  });

  factory CurriculumLessonModel.fromJson(Map<String, dynamic> json) {
    return CurriculumLessonModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? '',
    );
  }
}

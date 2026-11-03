import 'package:flutter/foundation.dart';

@immutable
class LabSubjectGroupModel {
  final String key;
  final String name;
  final int experimentsCount;

  const LabSubjectGroupModel({
    required this.key,
    required this.name,
    this.experimentsCount = 0,
  });

  factory LabSubjectGroupModel.fromJson(Map<String, dynamic> json) {
    return LabSubjectGroupModel(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      experimentsCount: int.tryParse(json['experiments_count']?.toString() ?? '') ?? 0,
    );
  }
}

@immutable
class LabSubjectModel {
  final int id;
  final String name;
  final int experimentsCount;

  const LabSubjectModel({
    required this.id,
    required this.name,
    this.experimentsCount = 0,
  });

  factory LabSubjectModel.fromJson(Map<String, dynamic> json) {
    return LabSubjectModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      experimentsCount: int.tryParse(json['experiments_count']?.toString() ?? '') ?? 0,
    );
  }
}

@immutable
class LabGradeModel {
  final int id;
  final String name;
  final int experimentsCount;
  final List<LabSubjectModel> subjects;

  const LabGradeModel({
    required this.id,
    required this.name,
    this.experimentsCount = 0,
    this.subjects = const [],
  });

  factory LabGradeModel.fromJson(Map<String, dynamic> json) {
    final rawSubs = json['subjects'];
    return LabGradeModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      experimentsCount: int.tryParse(json['experiments_count']?.toString() ?? '') ?? 0,
      subjects: rawSubs is List
          ? rawSubs
              .map((e) => LabSubjectModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }
}

@immutable
class LabStageModel {
  final int id;
  final String name;
  final int experimentsCount;
  final List<LabGradeModel> grades;

  const LabStageModel({
    required this.id,
    required this.name,
    this.experimentsCount = 0,
    this.grades = const [],
  });

  factory LabStageModel.fromJson(Map<String, dynamic> json) {
    final rawGrades = json['grades'];
    return LabStageModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      experimentsCount: int.tryParse(json['experiments_count']?.toString() ?? '') ?? 0,
      grades: rawGrades is List
          ? rawGrades
              .map((e) => LabGradeModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }
}

@immutable
class LabFiltersModel {
  final List<LabStageModel> stages;
  final List<LabSubjectGroupModel> subjectGroups;
  final int totalExperiments;

  const LabFiltersModel({
    this.stages = const [],
    this.subjectGroups = const [],
    this.totalExperiments = 0,
  });

  factory LabFiltersModel.fromJson(Map<String, dynamic> json) {
    final rawStages = json['stages'];
    final rawGroups = json['subject_groups'];
    final totals = json['totals'] is Map ? Map<String, dynamic>.from(json['totals'] as Map) : null;

    return LabFiltersModel(
      stages: rawStages is List
          ? rawStages
              .map((e) => LabStageModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      subjectGroups: rawGroups is List
          ? rawGroups
              .map((e) => LabSubjectGroupModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
      totalExperiments: int.tryParse(totals?['experiments']?.toString() ?? '') ?? 0,
    );
  }
}

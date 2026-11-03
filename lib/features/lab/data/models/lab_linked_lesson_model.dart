import 'package:flutter/foundation.dart';

/// Lesson linked to an experiment (`lessons` or `first_lesson` in `LAB_API.md` §1.1 & §1.2).
@immutable
class LabLinkedLessonModel {
  final int id;
  final String title;
  final String subject;
  final String grade;
  final String unit;
  final String chapter;

  const LabLinkedLessonModel({
    required this.id,
    required this.title,
    this.subject = '',
    this.grade = '',
    this.unit = '',
    this.chapter = '',
  });

  String get curriculumSubtitle {
    final parts = [subject, grade, unit, chapter]
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.join(' • ');
  }

  factory LabLinkedLessonModel.fromJson(Map<String, dynamic> json) {
    return LabLinkedLessonModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      chapter: json['chapter']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'grade': grade,
        'unit': unit,
        'chapter': chapter,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabLinkedLessonModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

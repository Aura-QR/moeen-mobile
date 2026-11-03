import 'package:flutter/foundation.dart';

@immutable
class AdminLabExperimentModel {
  final int? id;
  final String key;
  final String name;
  final String status; // 'published' | 'hidden'
  final String source; // 'hader' | 'community'
  final bool approved;
  final String? approvedAt;
  final bool featured;
  final int openReportsCount;
  final String? authorName;
  final int plays;
  final int lessonsCount;
  final String? area;
  final bool approximate;

  const AdminLabExperimentModel({
    this.id,
    required this.key,
    required this.name,
    this.status = 'published',
    this.source = 'hader',
    this.approved = false,
    this.approvedAt,
    this.featured = false,
    this.openReportsCount = 0,
    this.authorName,
    this.plays = 0,
    this.lessonsCount = 0,
    this.area,
    this.approximate = false,
  });

  bool get isPublished => status == 'published';
  bool get isCommunity => source == 'community';

  factory AdminLabExperimentModel.fromJson(Map<String, dynamic> json) {
    return AdminLabExperimentModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'published',
      source: json['source']?.toString() ?? 'hader',
      approved: json['approved'] == true || json['approved_at'] != null,
      approvedAt: json['approved_at']?.toString(),
      featured: json['featured'] == true,
      openReportsCount:
          int.tryParse(json['open_reports_count']?.toString() ?? '') ?? 0,
      authorName: json['author_name']?.toString(),
      plays: int.tryParse(json['plays']?.toString() ?? '') ?? 0,
      lessonsCount: int.tryParse(json['lessons_count']?.toString() ?? '') ?? 0,
      area: json['area']?.toString(),
      approximate: json['approximate'] == true,
    );
  }

  AdminLabExperimentModel copyWith({
    String? status,
    bool? approved,
    bool? featured,
    int? openReportsCount,
  }) {
    return AdminLabExperimentModel(
      id: id,
      key: key,
      name: name,
      status: status ?? this.status,
      source: source,
      approved: approved ?? this.approved,
      approvedAt: approvedAt,
      featured: featured ?? this.featured,
      openReportsCount: openReportsCount ?? this.openReportsCount,
      authorName: authorName,
      plays: plays,
      lessonsCount: lessonsCount,
      area: area,
      approximate: approximate,
    );
  }
}

@immutable
class AdminLabMistakeReportModel {
  final int id;
  final String message;
  final String status; // 'open' | 'done'
  final String? experimentKey;
  final String? experimentName;
  final String? teacherName;
  final String? teacherEmail;
  final String? createdAt;

  const AdminLabMistakeReportModel({
    required this.id,
    required this.message,
    this.status = 'open',
    this.experimentKey,
    this.experimentName,
    this.teacherName,
    this.teacherEmail,
    this.createdAt,
  });

  bool get isOpen => status == 'open';

  factory AdminLabMistakeReportModel.fromJson(Map<String, dynamic> json) {
    final exp = json['experiment'] is Map ? json['experiment'] as Map : null;
    final user = json['user'] is Map ? json['user'] as Map : null;

    return AdminLabMistakeReportModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      experimentKey: exp?['key']?.toString(),
      experimentName: exp?['name']?.toString(),
      teacherName: json['teacher_name']?.toString() ?? user?['name']?.toString(),
      teacherEmail: user?['email']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  AdminLabMistakeReportModel copyWith({String? status}) {
    return AdminLabMistakeReportModel(
      id: id,
      message: message,
      status: status ?? this.status,
      experimentKey: experimentKey,
      experimentName: experimentName,
      teacherName: teacherName,
      teacherEmail: teacherEmail,
      createdAt: createdAt,
    );
  }
}

@immutable
class AdminLabRequestModel {
  final int id;
  final String message;
  final String status; // 'open' | 'done'
  final int? lessonId;
  final String? lessonTitle;
  final String? teacherName;
  final String? teacherEmail;
  final String? createdAt;

  const AdminLabRequestModel({
    required this.id,
    required this.message,
    this.status = 'open',
    this.lessonId,
    this.lessonTitle,
    this.teacherName,
    this.teacherEmail,
    this.createdAt,
  });

  bool get isOpen => status == 'open';

  factory AdminLabRequestModel.fromJson(Map<String, dynamic> json) {
    final lesson = json['lesson'] is Map ? json['lesson'] as Map : null;
    final user = json['user'] is Map ? json['user'] as Map : null;

    return AdminLabRequestModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      lessonId: int.tryParse(json['lesson_id']?.toString() ?? lesson?['id']?.toString() ?? ''),
      lessonTitle: lesson?['title']?.toString(),
      teacherName: json['teacher_name']?.toString() ?? user?['name']?.toString(),
      teacherEmail: user?['email']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  AdminLabRequestModel copyWith({String? status}) {
    return AdminLabRequestModel(
      id: id,
      message: message,
      status: status ?? this.status,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      teacherName: teacherName,
      teacherEmail: teacherEmail,
      createdAt: createdAt,
    );
  }
}

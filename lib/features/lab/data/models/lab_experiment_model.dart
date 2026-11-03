import 'package:flutter/foundation.dart';
import 'package:moean/features/lab/data/models/lab_linked_lesson_model.dart';

export 'package:moean/features/lab/data/models/lab_linked_lesson_model.dart';

/// Argument passed to [LabExperimentScreen].
@immutable
class LabExperimentArgs {
  final String key;
  final String name;

  const LabExperimentArgs({required this.key, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabExperimentArgs && key == other.key && name == other.name;

  @override
  int get hashCode => key.hashCode ^ name.hashCode;
}

/// Argument passed to [LabLibraryScreen] to filter by lesson.
@immutable
class LabLibraryArgs {
  final int? lessonId;
  final String? lessonTitle;

  const LabLibraryArgs({this.lessonId, this.lessonTitle});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabLibraryArgs &&
          lessonId == other.lessonId &&
          lessonTitle == other.lessonTitle;

  @override
  int get hashCode => lessonId.hashCode ^ lessonTitle.hashCode;
}

/// L8 «معمل حضر الافتراضي» (LAB_API.md): Experiment Model.
@immutable
class LabExperimentModel {
  final String key;
  final String name;
  final String area;
  final String kind;
  final String display;
  final String observe;
  final bool approximate;
  final bool featured;
  final String source;
  final String? authorName;
  final int plays;
  final int lessonsCount;
  final String? url;
  final String? about;
  final LabLinkedLessonModel? firstLesson;
  final List<LabLinkedLessonModel> lessons;

  const LabExperimentModel({
    required this.key,
    required this.name,
    this.area = '',
    this.kind = 'formula',
    this.display = 'bars',
    this.observe = '',
    this.approximate = false,
    this.featured = false,
    this.source = 'hader',
    this.authorName,
    this.plays = 0,
    this.lessonsCount = 0,
    this.url,
    this.about,
    this.firstLesson,
    this.lessons = const [],
  });

  factory LabExperimentModel.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];
    final parsedLessons = rawLessons is List
        ? rawLessons
            .whereType<Map>()
            .map((e) => LabLinkedLessonModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <LabLinkedLessonModel>[];
    final rawFirst = json['first_lesson'];
    final parsedFirst = rawFirst is Map
        ? LabLinkedLessonModel.fromJson(Map<String, dynamic>.from(rawFirst))
        : (parsedLessons.isNotEmpty ? parsedLessons.first : null);

    return LabExperimentModel(
      key: json['key']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'formula',
      display: json['display']?.toString() ?? 'bars',
      observe: json['observe']?.toString() ?? '',
      approximate: json['approximate'] == true,
      featured: json['featured'] == true,
      source: json['source']?.toString() ?? 'hader',
      authorName: json['author_name']?.toString(),
      plays: int.tryParse(json['plays']?.toString() ?? '') ?? 0,
      lessonsCount: int.tryParse(json['lessons_count']?.toString() ?? '') ??
          parsedLessons.length,
      url: json['url']?.toString(),
      about: json['about']?.toString(),
      firstLesson: parsedFirst,
      lessons: parsedLessons,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabExperimentModel && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

/// Paginated list result from `GET /api/public/lab/experiments`.
@immutable
class LabExperimentsPage {
  final List<LabExperimentModel> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const LabExperimentsPage({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 24,
  });

  bool get hasMore => currentPage < lastPage;

  factory LabExperimentsPage.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = rawData is List
        ? rawData
            .map((e) => LabExperimentModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <LabExperimentModel>[];
    final meta = json['meta'] is Map ? Map<String, dynamic>.from(json['meta'] as Map) : null;
    return LabExperimentsPage(
      items: items,
      currentPage: int.tryParse(meta?['current_page']?.toString() ?? '') ?? 1,
      lastPage: int.tryParse(meta?['last_page']?.toString() ?? '') ?? 1,
      total: int.tryParse(meta?['total']?.toString() ?? '') ?? items.length,
      perPage: int.tryParse(meta?['per_page']?.toString() ?? '') ?? 24,
    );
  }
}

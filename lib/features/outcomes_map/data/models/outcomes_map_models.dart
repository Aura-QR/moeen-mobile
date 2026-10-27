/// Models and pure operations for `outcomes_map` documents
/// («خريطة نواتج التعلم», DOCUMENTS_API.md § 16).
library;

import 'package:equatable/equatable.dart';
import 'package:moean/features/exam_generation/data/models/curriculum_models.dart';

abstract final class OutcomesMapLimits {
  static const int maxUnits = 12;
  static const int maxLessonsPerUnit = 15;
  static const int maxOutcomesPerLesson = 4;
  static const int maxTitleLength = 150;
  static const int maxLessonTitleLength = 150;
  static const int maxOutcomeLength = 120;

  /// Lessons per `lesson_outcomes` AI job; larger units are split.
  static const int aiLessonsPerJob = 8;

  /// A unit above this many outcomes always prints as a table.
  static const int treeTableThreshold = 30;
}

/// The two document terms the teacher picks when starting a new map.
abstract final class OutcomesMapSemester {
  static const String first = '1';
  static const String second = '2';

  static String labelKey(String semester) =>
      semester == second ? 'outcomes_map_semester_second' : 'outcomes_map_semester_first';
}

enum OutcomesMapLayout {
  table('table', 'outcomes_map_layout_table'),
  tree('tree', 'outcomes_map_layout_tree');

  final String jsonValue;
  final String labelKey;

  const OutcomesMapLayout(this.jsonValue, this.labelKey);

  static OutcomesMapLayout fromJson(dynamic raw) {
    final value = raw?.toString() ?? '';
    return OutcomesMapLayout.values.firstWhere(
      (item) => item.jsonValue == value,
      orElse: () => OutcomesMapLayout.table,
    );
  }
}

/// The signature lines printed under the map.
enum OutcomesMapSignature {
  teacher('teacher'),
  principal('principal');

  final String jsonValue;

  const OutcomesMapSignature(this.jsonValue);

  String get labelKey => 'outcomes_map_signature_$jsonValue';
}

/// One lesson row: its title and up to four learning outcomes.
class OutcomeLesson extends Equatable {
  /// The curriculum lesson this row came from; null for a lesson the teacher
  /// added by hand, which the AI cannot suggest for.
  final int? lessonId;
  final String title;
  final List<String> outcomes;
  final Map<String, dynamic> extra;

  const OutcomeLesson({
    this.lessonId,
    this.title = '',
    this.outcomes = const [],
    this.extra = const {},
  });

  static const _ownKeys = {'lesson_id', 'id', 'title', 'name', 'outcomes'};

  bool get hasOutcomes => outcomes.any((o) => o.trim().isNotEmpty);

  factory OutcomeLesson.fromJson(Map<String, dynamic> json) {
    final rawOutcomes = json['outcomes'];
    return OutcomeLesson(
      lessonId: int.tryParse((json['lesson_id'] ?? json['id'])?.toString() ?? ''),
      title: (json['title'] ?? json['name'])?.toString() ?? '',
      outcomes: rawOutcomes is List
          ? [for (final o in rawOutcomes) o?.toString() ?? '']
          : const [],
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  Map<String, dynamic> toJson() => {
        ...extra,
        if (lessonId != null) 'lesson_id': lessonId,
        'title': title.trim(),
        'outcomes': [
          for (final outcome in outcomes)
            if (outcome.trim().isNotEmpty) outcome.trim(),
        ],
      };

  OutcomeLesson copyWith({
    int? lessonId,
    String? title,
    List<String>? outcomes,
  }) =>
      OutcomeLesson(
        lessonId: lessonId ?? this.lessonId,
        title: title ?? this.title,
        outcomes: outcomes ?? this.outcomes,
        extra: extra,
      );

  @override
  List<Object?> get props => [lessonId, title, outcomes, extra];
}

/// One unit: a name and its lessons.
class OutcomeUnit extends Equatable {
  final String name;
  final List<OutcomeLesson> lessons;
  final Map<String, dynamic> extra;

  const OutcomeUnit({
    this.name = '',
    this.lessons = const [],
    this.extra = const {},
  });

  static const _ownKeys = {'name', 'title', 'lessons'};

  /// Total outcomes across the unit's lessons, for the «يُطبع جدولًا» hint.
  int get outcomesCount =>
      lessons.fold(0, (sum, lesson) => sum + lesson.outcomes.where((o) => o.trim().isNotEmpty).length);

  /// Lesson ids that still have no outcomes, chunked for AI jobs.
  List<int> get fillableLessonIds => [
        for (final lesson in lessons)
          if (lesson.lessonId != null && !lesson.hasOutcomes) lesson.lessonId!,
      ];

  factory OutcomeUnit.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];
    return OutcomeUnit(
      name: (json['name'] ?? json['title'])?.toString() ?? '',
      lessons: rawLessons is List
          ? [
              for (final item in rawLessons.whereType<Map>())
                OutcomeLesson.fromJson(Map<String, dynamic>.from(item)),
            ]
          : const [],
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  Map<String, dynamic> toJson() => {
        ...extra,
        'name': name.trim(),
        'lessons': [for (final lesson in lessons) lesson.toJson()],
      };

  OutcomeUnit copyWith({String? name, List<OutcomeLesson>? lessons}) => OutcomeUnit(
        name: name ?? this.name,
        lessons: lessons ?? this.lessons,
        extra: extra,
      );

  @override
  List<Object?> get props => [name, lessons, extra];
}

class OutcomesMapInput extends Equatable {
  final int? subjectId;
  final String semester;
  final String title;
  final OutcomesMapLayout layout;
  final List<OutcomeUnit> units;
  final Set<OutcomesMapSignature> signatures;
  final Map<String, dynamic> header;
  final Map<String, dynamic> extra;

  const OutcomesMapInput({
    this.subjectId,
    this.semester = OutcomesMapSemester.first,
    this.title = '',
    this.layout = OutcomesMapLayout.table,
    this.units = const [],
    this.signatures = const {OutcomesMapSignature.teacher, OutcomesMapSignature.principal},
    this.header = const {},
    this.extra = const {},
  });

  static const _ownKeys = {
    'subject_id',
    'semester',
    'title',
    'layout',
    'units',
    'signatures',
    'header',
  };

  bool get hasAnyFillableLesson => units.any((unit) => unit.fillableLessonIds.isNotEmpty);

  bool get hasEmptyLesson =>
      units.any((unit) => unit.lessons.any((lesson) => !lesson.hasOutcomes));

  bool get canAddUnit => units.length < OutcomesMapLimits.maxUnits;

  bool canAddLesson(int unitIndex) =>
      unitIndex >= 0 &&
      unitIndex < units.length &&
      units[unitIndex].lessons.length < OutcomesMapLimits.maxLessonsPerUnit;

  bool canAddOutcome(int unitIndex, int lessonIndex) {
    final lesson = lessonAt(unitIndex, lessonIndex);
    return lesson != null && lesson.outcomes.length < OutcomesMapLimits.maxOutcomesPerLesson;
  }

  OutcomeLesson? lessonAt(int unitIndex, int lessonIndex) {
    if (unitIndex < 0 || unitIndex >= units.length) return null;
    final lessons = units[unitIndex].lessons;
    if (lessonIndex < 0 || lessonIndex >= lessons.length) return null;
    return lessons[lessonIndex];
  }

  factory OutcomesMapInput.fromJson(Map<String, dynamic> json) {
    final rawUnits = json['units'];
    final rawSignatures = json['signatures'];
    return OutcomesMapInput(
      subjectId: int.tryParse(json['subject_id']?.toString() ?? ''),
      semester: json['semester']?.toString() ?? OutcomesMapSemester.first,
      title: json['title']?.toString() ?? '',
      layout: OutcomesMapLayout.fromJson(json['layout']),
      units: rawUnits is List
          ? [
              for (final item in rawUnits.whereType<Map>())
                OutcomeUnit.fromJson(Map<String, dynamic>.from(item)),
            ]
          : const [],
      signatures: rawSignatures is List
          ? {
              for (final signature in OutcomesMapSignature.values)
                if (rawSignatures.contains(signature.jsonValue)) signature,
            }
          : const {OutcomesMapSignature.teacher, OutcomesMapSignature.principal},
      header: json['header'] is Map ? Map<String, dynamic>.from(json['header'] as Map) : const {},
      extra: {
        for (final entry in json.entries)
          if (!_ownKeys.contains(entry.key)) entry.key: entry.value,
      },
    );
  }

  /// Builds the starting skeleton from the subject's chapters, keeping only
  /// [semester]'s lessons and grouping the chapters by `unit_id`.
  factory OutcomesMapInput.fromSkeleton({
    required int subjectId,
    required String semester,
    required String title,
    required List<CurriculumChapterModel> chapters,
  }) {
    final ordered = <String>[];
    final grouped = <String, OutcomeUnit>{};

    for (final chapter in chapters) {
      final lessons = chapter.lessonsInSemester(semester);
      if (lessons.isEmpty) continue;
      final key = (chapter.unitId != null && chapter.unitId!.trim().isNotEmpty)
          ? chapter.unitId!.trim()
          : 'chapter-${chapter.chapterId}';
      final name = (chapter.unitName != null && chapter.unitName!.trim().isNotEmpty)
          ? chapter.unitName!.trim()
          : chapter.title.trim();
      final rows = [
        for (final lesson in lessons)
          OutcomeLesson(lessonId: lesson.id, title: lesson.title),
      ];
      final existing = grouped[key];
      if (existing == null) {
        ordered.add(key);
        grouped[key] = OutcomeUnit(name: name, lessons: rows);
      } else {
        grouped[key] = existing.copyWith(lessons: [...existing.lessons, ...rows]);
      }
    }

    final units = [for (final key in ordered) grouped[key]!];
    return OutcomesMapInput(
      subjectId: subjectId,
      semester: semester,
      title: title,
      units: units.isEmpty ? const [OutcomeUnit()] : units,
    );
  }

  Map<String, dynamic> toJson() => {
        ...extra,
        if (subjectId != null) 'subject_id': subjectId,
        'semester': semester,
        'title': title.trim(),
        'layout': layout.jsonValue,
        'units': [for (final unit in units) unit.toJson()],
        'signatures': [for (final signature in signatures) signature.jsonValue],
        if (header.isNotEmpty) 'header': header,
      };

  OutcomesMapInput copyWith({
    int? subjectId,
    String? semester,
    String? title,
    OutcomesMapLayout? layout,
    List<OutcomeUnit>? units,
    Set<OutcomesMapSignature>? signatures,
    Map<String, dynamic>? header,
  }) =>
      OutcomesMapInput(
        subjectId: subjectId ?? this.subjectId,
        semester: semester ?? this.semester,
        title: title ?? this.title,
        layout: layout ?? this.layout,
        units: units ?? this.units,
        signatures: signatures ?? this.signatures,
        header: header ?? this.header,
        extra: extra,
      );

  // --- Pure unit / lesson / outcome mutations -----------------------------

  OutcomesMapInput _replaceUnit(int unitIndex, OutcomeUnit Function(OutcomeUnit) transform) {
    if (unitIndex < 0 || unitIndex >= units.length) return this;
    final next = [...units];
    next[unitIndex] = transform(next[unitIndex]);
    return copyWith(units: next);
  }

  OutcomesMapInput _replaceLesson(
    int unitIndex,
    int lessonIndex,
    OutcomeLesson Function(OutcomeLesson) transform,
  ) =>
      _replaceUnit(unitIndex, (unit) {
        if (lessonIndex < 0 || lessonIndex >= unit.lessons.length) return unit;
        final lessons = [...unit.lessons];
        lessons[lessonIndex] = transform(lessons[lessonIndex]);
        return unit.copyWith(lessons: lessons);
      });

  OutcomesMapInput addUnit() {
    if (!canAddUnit) return this;
    return copyWith(units: [...units, const OutcomeUnit()]);
  }

  OutcomesMapInput deleteUnit(int unitIndex) {
    if (unitIndex < 0 || unitIndex >= units.length) return this;
    final next = [...units]..removeAt(unitIndex);
    return copyWith(units: next);
  }

  OutcomesMapInput updateUnitName(int unitIndex, String name) =>
      _replaceUnit(unitIndex, (unit) => unit.copyWith(name: name));

  OutcomesMapInput addLesson(int unitIndex) {
    if (!canAddLesson(unitIndex)) return this;
    return _replaceUnit(
      unitIndex,
      (unit) => unit.copyWith(lessons: [...unit.lessons, const OutcomeLesson(outcomes: [''])]),
    );
  }

  OutcomesMapInput deleteLesson(int unitIndex, int lessonIndex) => _replaceUnit(unitIndex, (unit) {
        if (lessonIndex < 0 || lessonIndex >= unit.lessons.length) return unit;
        final lessons = [...unit.lessons]..removeAt(lessonIndex);
        return unit.copyWith(lessons: lessons);
      });

  OutcomesMapInput updateLessonTitle(int unitIndex, int lessonIndex, String title) =>
      _replaceLesson(unitIndex, lessonIndex, (lesson) => lesson.copyWith(title: title));

  OutcomesMapInput addOutcome(int unitIndex, int lessonIndex) {
    if (!canAddOutcome(unitIndex, lessonIndex)) return this;
    return _replaceLesson(
      unitIndex,
      lessonIndex,
      (lesson) => lesson.copyWith(outcomes: [...lesson.outcomes, '']),
    );
  }

  OutcomesMapInput updateOutcome(int unitIndex, int lessonIndex, int outcomeIndex, String text) =>
      _replaceLesson(unitIndex, lessonIndex, (lesson) {
        if (outcomeIndex < 0 || outcomeIndex >= lesson.outcomes.length) return lesson;
        final outcomes = [...lesson.outcomes];
        outcomes[outcomeIndex] = text;
        return lesson.copyWith(outcomes: outcomes);
      });

  OutcomesMapInput deleteOutcome(int unitIndex, int lessonIndex, int outcomeIndex) =>
      _replaceLesson(unitIndex, lessonIndex, (lesson) {
        if (outcomeIndex < 0 || outcomeIndex >= lesson.outcomes.length) return lesson;
        final outcomes = [...lesson.outcomes]..removeAt(outcomeIndex);
        return lesson.copyWith(outcomes: outcomes);
      });

  /// Fills a unit's lessons from an AI `result.lessons[]`, matching by
  /// `lesson_id` and only where the lesson still has no outcomes.
  OutcomesMapInput fillUnitFromAi(int unitIndex, Map<int, List<String>> outcomesByLessonId) =>
      _replaceUnit(unitIndex, (unit) {
        final lessons = [
          for (final lesson in unit.lessons)
            if (lesson.lessonId != null &&
                !lesson.hasOutcomes &&
                (outcomesByLessonId[lesson.lessonId]?.isNotEmpty ?? false))
              lesson.copyWith(
                outcomes: outcomesByLessonId[lesson.lessonId]!
                    .take(OutcomesMapLimits.maxOutcomesPerLesson)
                    .toList(),
              )
            else
              lesson,
        ];
        return unit.copyWith(lessons: lessons);
      });

  @override
  List<Object?> get props => [subjectId, semester, title, layout, units, signatures, header, extra];
}

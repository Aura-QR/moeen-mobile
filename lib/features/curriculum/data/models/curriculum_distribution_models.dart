// Models for Curriculum Distribution & Books feature
// Based on the API shape described in CURRICULUM_DISTRIBUTION_AND_BOOKS.md

// ──────────────────────────────────────────────────────────────────────────────
// Plans
// ──────────────────────────────────────────────────────────────────────────────

class CurriculumPlanModel {
  final int id;
  final String subjectName;
  final String gradeName;
  final int semester;
  final String academicYear;

  const CurriculumPlanModel({
    required this.id,
    required this.subjectName,
    required this.gradeName,
    required this.semester,
    required this.academicYear,
  });

  factory CurriculumPlanModel.fromJson(Map<String, dynamic> json) {
    return CurriculumPlanModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      subjectName: json['subject_name'] as String? ??
          (json['subject'] is Map ? json['subject']['name'] as String? : null) ??
          (json['subject'] is String ? json['subject'] as String : null) ??
          json['name'] as String? ??
          '',
      gradeName: json['grade_name'] as String? ??
          (json['grade'] is Map ? json['grade']['name'] as String? : null) ??
          (json['grade'] is String ? json['grade'] as String : null) ??
          '',
      semester: int.tryParse(json['semester']?.toString() ?? '') ?? 1,
      academicYear: json['academic_year']?.toString() ?? '',
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Week items (lessons inside a week)
// ──────────────────────────────────────────────────────────────────────────────

class CurriculumWeekItem {
  final int id;
  final String title;
  final String unit;
  final String kind; // lesson | review | exam | intro | activity
  final int? lessonId;
  final bool canPrepare;

  const CurriculumWeekItem({
    required this.id,
    required this.title,
    required this.unit,
    required this.kind,
    this.lessonId,
    required this.canPrepare,
  });

  factory CurriculumWeekItem.fromJson(Map<String, dynamic> json) {
    return CurriculumWeekItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      kind: json['kind'] as String? ?? 'lesson',
      lessonId: int.tryParse(json['lesson_id']?.toString() ?? ''),
      canPrepare: json['can_prepare'] as bool? ?? false,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Week card (teaching | holiday | exam)
// ──────────────────────────────────────────────────────────────────────────────

class CurriculumWeekModel {
  final String type; // teaching | holiday | exam
  final int? weekNumber;
  final String? title;
  final String startsOn;
  final String endsOn;
  final String? startsOnHijri;
  final String? endsOnHijri;
  final bool isCurrent;
  final List<String> notes;
  final List<CurriculumWeekItem> items;

  const CurriculumWeekModel({
    required this.type,
    this.weekNumber,
    this.title,
    required this.startsOn,
    required this.endsOn,
    this.startsOnHijri,
    this.endsOnHijri,
    required this.isCurrent,
    required this.notes,
    required this.items,
  });

  bool get isTeaching => type == 'teaching';
  bool get isHoliday => type == 'holiday';
  bool get isExam => type == 'exam';

  factory CurriculumWeekModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawNotes = json['notes'] as List<dynamic>? ?? [];
    return CurriculumWeekModel(
      type: json['type'] as String? ?? 'teaching',
      weekNumber: int.tryParse(json['week_number']?.toString() ?? ''),
      title: json['title'] as String?,
      startsOn: json['starts_on'] as String? ?? '',
      endsOn: json['ends_on'] as String? ?? '',
      startsOnHijri: json['starts_on_hijri'] as String?,
      endsOnHijri: json['ends_on_hijri'] as String?,
      isCurrent: json['is_current'] as bool? ?? false,
      notes: rawNotes.map((e) => e.toString()).toList(),
      items: rawItems
          .map((e) => CurriculumWeekItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Full plan detail (plan meta + all weeks)
// ──────────────────────────────────────────────────────────────────────────────

class CurriculumPlanDetailModel {
  final CurriculumPlanModel plan;
  final List<CurriculumWeekModel> weeks;

  const CurriculumPlanDetailModel({
    required this.plan,
    required this.weeks,
  });

  factory CurriculumPlanDetailModel.fromJson(Map<String, dynamic> json) {
    // The backend may wrap plan metadata under a 'plan' key or inline it
    final planData = (json['plan'] as Map<String, dynamic>?) ?? json;
    final rawWeeks = json['weeks'] as List<dynamic>? ?? [];
    return CurriculumPlanDetailModel(
      plan: CurriculumPlanModel.fromJson(planData),
      weeks: rawWeeks
          .map((e) => CurriculumWeekModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Books
// ──────────────────────────────────────────────────────────────────────────────

class CurriculumBookModel {
  final int id;
  final String title;
  final String subjectName;
  final String? sizeMb;
  final String? coverUrl;

  const CurriculumBookModel({
    required this.id,
    required this.title,
    required this.subjectName,
    this.sizeMb,
    this.coverUrl,
  });

  factory CurriculumBookModel.fromJson(Map<String, dynamic> json) {
    // Some APIs might return the ID under a different key, e.g. book_id or uuid.
    final rawId = json['id'] ?? json['book_id'] ?? json['uuid'] ?? 0;
    
    return CurriculumBookModel(
      id: int.tryParse(rawId.toString()) ?? 0,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      subjectName: json['subject_name'] as String? ?? '',
      sizeMb: json['size_mb']?.toString(),
      coverUrl: json['cover_url'] as String?,
    );
  }
}

class CurriculumBookDownloadModel {
  final String url;
  final String expiresAt;
  final String fileName;
  final double sizeMb;

  const CurriculumBookDownloadModel({
    required this.url,
    required this.expiresAt,
    required this.fileName,
    required this.sizeMb,
  });

  factory CurriculumBookDownloadModel.fromJson(Map<String, dynamic> json) {
    return CurriculumBookDownloadModel(
      url: json['url'] as String? ?? '',
      expiresAt: json['expires_at'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      sizeMb: double.tryParse(json['size_mb']?.toString() ?? '') ?? 0.0,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Progress (teacher-specific)
// ──────────────────────────────────────────────────────────────────────────────

class CurriculumProgressModel {
  final int totalWeeks;
  final int completedWeeks;
  final int currentWeekNumber;
  final String status; // ahead | on_track | behind
  final int weeksAheadOrBehind;

  const CurriculumProgressModel({
    required this.totalWeeks,
    required this.completedWeeks,
    required this.currentWeekNumber,
    required this.status,
    required this.weeksAheadOrBehind,
  });

  factory CurriculumProgressModel.fromJson(Map<String, dynamic> json) {
    return CurriculumProgressModel(
      totalWeeks: json['total_weeks'] as int? ?? 0,
      completedWeeks: json['completed_weeks'] as int? ?? 0,
      currentWeekNumber: json['current_week_number'] as int? ?? 0,
      status: json['status'] as String? ?? 'on_track',
      weeksAheadOrBehind: json['weeks_ahead_or_behind'] as int? ?? 0,
    );
  }
}

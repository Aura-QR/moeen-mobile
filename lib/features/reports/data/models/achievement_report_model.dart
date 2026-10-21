/// `GET /reports/achievements`. See PORTFOLIO_AND_ACHIEVEMENTS_API.md § 2.
class AchievementReportModel {
  final String period;
  final DateTime from;
  final DateTime to;
  final AchievementTotalsModel totals;
  final List<AchievementDayModel> byDay;

  /// Capped at 300 by the API; [AchievementTotalsModel.lessonsPrepared] is the full count.
  final List<AchievementLessonModel> lessons;

  const AchievementReportModel({
    required this.period,
    required this.from,
    required this.to,
    required this.totals,
    required this.byDay,
    required this.lessons,
  });

  factory AchievementReportModel.fromJson(Map<String, dynamic> json) {
    final byDay = json['by_day'];
    final lessons = json['lessons'];
    return AchievementReportModel(
      period: json['period']?.toString() ?? '',
      from: DateTime.parse(json['from'].toString()),
      to: DateTime.parse(json['to'].toString()),
      totals: AchievementTotalsModel.fromJson(
        json['totals'] is Map<String, dynamic> ? json['totals'] as Map<String, dynamic> : const {},
      ),
      byDay: byDay is List
          ? byDay.whereType<Map<String, dynamic>>().map(AchievementDayModel.fromJson).toList()
          : const [],
      lessons: lessons is List
          ? lessons.whereType<Map<String, dynamic>>().map(AchievementLessonModel.fromJson).toList()
          : const [],
    );
  }
}

class AchievementTotalsModel {
  final int lessonsPrepared;
  final int exams;
  final int educationalReports;
  final int presentations;
  final int worksheets;

  const AchievementTotalsModel({
    required this.lessonsPrepared,
    required this.exams,
    required this.educationalReports,
    required this.presentations,
    required this.worksheets,
  });

  factory AchievementTotalsModel.fromJson(Map<String, dynamic> json) {
    return AchievementTotalsModel(
      lessonsPrepared: _asInt(json['lessons_prepared']),
      exams: _asInt(json['exams']),
      educationalReports: _asInt(json['educational_reports']),
      presentations: _asInt(json['presentations']),
      worksheets: _asInt(json['worksheets']),
    );
  }
}

class AchievementDayModel {
  final DateTime date;
  final int lessonsPrepared;

  const AchievementDayModel({required this.date, required this.lessonsPrepared});

  factory AchievementDayModel.fromJson(Map<String, dynamic> json) {
    return AchievementDayModel(
      date: DateTime.parse(json['date'].toString()),
      lessonsPrepared: _asInt(json['lessons_prepared']),
    );
  }
}

class AchievementLessonModel {
  final int id;
  final String title;

  /// Wall-clock Saudi time, whatever the device's time zone.
  final DateTime? completedAt;

  const AchievementLessonModel({required this.id, required this.title, required this.completedAt});

  factory AchievementLessonModel.fromJson(Map<String, dynamic> json) {
    final parsed = DateTime.tryParse(json['completed_at']?.toString() ?? '');
    return AchievementLessonModel(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? '',
      completedAt: parsed?.toUtc().add(const Duration(hours: 3)),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

import 'dart:math';

/// The report windows from `GET /reports/achievements?period=`.
/// The API computes them in Saudi time; a week runs Sunday to Saturday.
enum AchievementPeriod {
  day('day', 'achievement_period_day'),
  week('week', 'achievement_period_week'),
  month('month', 'achievement_period_month');

  const AchievementPeriod(this.apiValue, this.labelKey);

  final String apiValue;
  final String labelKey;

  /// Moves [date] by one period; [step] is 1 or -1.
  /// Month steps keep the day where possible (Mar 31 → Feb 28).
  DateTime shift(DateTime date, int step) {
    switch (this) {
      case AchievementPeriod.day:
        return DateTime(date.year, date.month, date.day + step);
      case AchievementPeriod.week:
        return DateTime(date.year, date.month, date.day + 7 * step);
      case AchievementPeriod.month:
        final firstOfTarget = DateTime(date.year, date.month + step);
        final lastDay = DateTime(firstOfTarget.year, firstOfTarget.month + 1, 0).day;
        return DateTime(firstOfTarget.year, firstOfTarget.month, min(date.day, lastDay));
    }
  }
}

/// `YYYY-MM-DD`, as the API expects for `date`.
String formatApiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/reports/data/models/achievement_period.dart';

void main() {
  group('AchievementPeriod.shift', () {
    test('day moves one day and crosses month ends', () {
      expect(AchievementPeriod.day.shift(DateTime(2026, 10, 31), 1), DateTime(2026, 11, 1));
      expect(AchievementPeriod.day.shift(DateTime(2026, 10, 1), -1), DateTime(2026, 9, 30));
    });

    test('week moves seven days', () {
      expect(AchievementPeriod.week.shift(DateTime(2026, 10, 21), 1), DateTime(2026, 10, 28));
      expect(AchievementPeriod.week.shift(DateTime(2026, 10, 21), -1), DateTime(2026, 10, 14));
    });

    test('month keeps the day when it exists', () {
      expect(AchievementPeriod.month.shift(DateTime(2026, 10, 21), 1), DateTime(2026, 11, 21));
    });

    test('month clamps to the last day of a shorter month', () {
      expect(AchievementPeriod.month.shift(DateTime(2026, 3, 31), -1), DateTime(2026, 2, 28));
      expect(AchievementPeriod.month.shift(DateTime(2028, 1, 31), 1), DateTime(2028, 2, 29));
    });

    test('month crosses the year boundary', () {
      expect(AchievementPeriod.month.shift(DateTime(2026, 12, 15), 1), DateTime(2027, 1, 15));
      expect(AchievementPeriod.month.shift(DateTime(2026, 1, 15), -1), DateTime(2025, 12, 15));
    });
  });

  test('formatApiDate pads to YYYY-MM-DD', () {
    expect(formatApiDate(DateTime(2026, 3, 5)), '2026-03-05');
    expect(formatApiDate(DateTime(2026, 10, 21)), '2026-10-21');
  });
}

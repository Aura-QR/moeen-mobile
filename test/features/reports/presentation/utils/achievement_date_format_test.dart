import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/reports/presentation/utils/achievement_date_format.dart';

void main() {
  const months = {'month_10': 'أكتوبر', 'month_12': 'ديسمبر', 'month_1': 'يناير'};
  String translate(String key) =>
      key == 'achievement_range' ? 'من {from} إلى {to}' : months[key] ?? key;

  test('a range in one year shows the year once', () {
    expect(
      formatAchievementRange(DateTime(2026, 10, 18), DateTime(2026, 10, 24), translate),
      'من 18 أكتوبر إلى 24 أكتوبر 2026',
    );
  });

  test('a range across years shows both years', () {
    expect(
      formatAchievementRange(DateTime(2026, 12, 27), DateTime(2027, 1, 2), translate),
      'من 27 ديسمبر 2026 إلى 2 يناير 2027',
    );
  });

  test('a single day has no range words', () {
    expect(formatAchievementRange(DateTime(2026, 10, 21), DateTime(2026, 10, 21), translate), '21 أكتوبر 2026');
  });

  test('formatFullDateRange shows both years with a dash', () {
    expect(
      formatFullDateRange(DateTime(2026, 10, 18), DateTime(2026, 10, 24), translate),
      '18 أكتوبر 2026 – 24 أكتوبر 2026',
    );
    expect(formatFullDateRange(DateTime(2026, 10, 21), DateTime(2026, 10, 21), translate), '21 أكتوبر 2026');
  });

  test('formatTime pads hours and minutes', () {
    expect(formatTime(DateTime(2026, 10, 18, 9, 5)), '09:05');
  });
}

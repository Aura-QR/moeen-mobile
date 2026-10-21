/// Looks up a translation key; `appTranslation().get` in the app.
typedef Translate = String Function(String key);

/// «18 أكتوبر».
String formatDayMonth(DateTime date, Translate translate) =>
    '${date.day} ${translate('month_${date.month}')}';

/// «من 18 أكتوبر إلى 24 أكتوبر 2026», or «21 أكتوبر 2026» for a single day.
String formatAchievementRange(DateTime from, DateTime to, Translate translate) {
  if (from.year == to.year && from.month == to.month && from.day == to.day) {
    return '${formatDayMonth(from, translate)} ${from.year}';
  }
  final start = from.year == to.year
      ? formatDayMonth(from, translate)
      : '${formatDayMonth(from, translate)} ${from.year}';
  return translate('achievement_range')
      .replaceAll('{from}', start)
      .replaceAll('{to}', '${formatDayMonth(to, translate)} ${to.year}');
}

/// «18 أكتوبر 2026 – 24 أكتوبر 2026», or «21 أكتوبر 2026» for a single day.
String formatFullDateRange(DateTime from, DateTime to, Translate translate) {
  final start = '${formatDayMonth(from, translate)} ${from.year}';
  final end = '${formatDayMonth(to, translate)} ${to.year}';
  return start == end ? start : '$start – $end';
}

/// «09:12».
String formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

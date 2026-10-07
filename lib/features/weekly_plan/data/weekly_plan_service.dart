import 'dart:convert';
import 'dart:io';

import 'package:hijri/hijri_calendar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:moean/core/network/remote/api_endpoints.dart';
import 'package:moean/core/network/remote/dio_helper.dart';
import 'package:moean/features/weekly_plan/data/weekly_plan_docx.dart';

class WeeklyPlanException implements Exception {
  const WeeklyPlanException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Exports a week of the teacher's schedule as the ministry's weekly plan.
///
/// The week comes from `GET /schedule?week=`, the same weeks the Hader site
/// reads. They are saved by the extension code running in the Madrasati
/// screen, which stores every week the teacher opens there.
class WeeklyPlanService {
  /// Madrasati weeks follow Riyadh time (UTC+3), whatever the phone's zone.
  static DateTime sundayOf(int weeksFromNow) {
    final riyadh = DateTime.now().toUtc().add(const Duration(hours: 3));
    final today = DateTime(riyadh.year, riyadh.month, riyadh.day);
    // DateTime.weekday: Monday = 1 … Sunday = 7.
    return today.subtract(Duration(days: today.weekday % 7)).add(Duration(days: weeksFromNow * 7));
  }

  static String isoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// The week's Sunday-to-Thursday range as Madrasati shows it,
  /// e.g. "1448/04/23 - 1448/04/27".
  static String hijriPeriod(DateTime sunday) {
    String format(DateTime date) {
      final h = HijriCalendar.fromDate(date);
      return '${h.hYear}/${h.hMonth.toString().padLeft(2, '0')}/${h.hDay.toString().padLeft(2, '0')}';
    }

    return '${format(sunday)} - ${format(sunday.add(const Duration(days: 4)))}';
  }

  /// Builds the sheet for the week starting [sunday] and opens the share sheet,
  /// from which the teacher saves it or sends it on.
  static Future<void> exportAndShare(DateTime sunday, {String? teacherName}) async {
    final weekDate = isoDate(sunday);
    final result = await DioHelper.getData(url: scheduleApi, query: {'week': weekDate});
    final raw = result.fold(
      (error) => throw WeeklyPlanException(
        error.startsWith('__402__:') ? error.split(':').skip(2).join(':') : 'تعذر تحميل جدول هذا الأسبوع. تحقق من اتصالك.',
      ),
      (response) => response.data,
    );
    final data = raw is String ? _decode(raw) : raw;

    final periods = <Map<String, dynamic>>[];
    final days = data is Map ? (data['days'] ?? data['schedule']) : null;
    if (days is List) {
      for (final day in days) {
        final dayPeriods = day is Map ? day['periods'] : null;
        if (dayPeriods is! List) continue;
        for (final period in dayPeriods) {
          if (period is Map) periods.add(Map<String, dynamic>.from(period));
        }
      }
    }
    if (periods.isEmpty) {
      throw const WeeklyPlanException(
        'لا توجد حصص محفوظة لهذا الأسبوع. افتح جدول هذا الأسبوع في شاشة مدرستي ثم أعد المحاولة.',
      );
    }

    final lessons = <WeeklyPlanLesson>[];
    String? grade;
    for (final period in periods) {
      final dayOfWeek = int.tryParse('${period['day_of_week']}') ?? -1;
      if (dayOfWeek < 0 || dayOfWeek > 4) continue;
      final periodNumber = int.tryParse('${period['period_number']}') ?? 0;
      grade ??= _text(period['classroom_name']).isEmpty ? null : _text(period['classroom_name']);

      // Only prepared lessons are written into the sheet. Every other period
      // keeps its row but stays blank, for the teacher to fill by hand.
      if (!_isPrepared(period)) {
        lessons.add(WeeklyPlanLesson(dayOfWeek: dayOfWeek, periodNumber: periodNumber));
        continue;
      }
      lessons.add(WeeklyPlanLesson(
        dayOfWeek: dayOfWeek,
        periodNumber: periodNumber,
        subject: _text(period['subject_name']),
        topic: _topic(period),
      ));
    }

    final bytes = WeeklyPlanDocx.build(WeeklyPlanInput(
      weekStart: sunday,
      lessons: lessons,
      teacherName: teacherName,
      grade: grade,
    ));

    final dir = await getTemporaryDirectory();
    final fileName = 'خطة التعلم الأسبوعية - $weekDate.docx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(ShareParams(
      files: [
        XFile(
          file.path,
          mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          name: fileName,
        ),
      ],
      text: 'خطة التعلم الأسبوعية (${hijriPeriod(sunday)})',
    ));
  }

  /// The site's rule (schedule page, getLessonStatus): Madrasati's own card
  /// status decides, and the local preparation record only fills in when
  /// Madrasati's status says nothing.
  static bool _isPrepared(Map<String, dynamic> period) {
    final madrasati = _text(period['madrasati_status']).toLowerCase();
    if (_text(period['subject_name']) == 'نشاط' || madrasati == 'activity') return false;
    if (const ['ready', 'prepared', 'done', 'completed'].contains(madrasati)) return true;
    if (const ['expired', 'incomplete', 'not_prepared', 'unprepared', 'waiting', 'pending', 'no_lesson']
        .contains(madrasati)) {
      return false;
    }
    final preparation = _text(period['preparation_status']).toLowerCase();
    return period['is_prepared'] == true || preparation == 'done' || preparation == 'completed';
  }

  static const _placeholders = {'اختر الدرس', 'اختار الدرس', 'الدرس الأساسي', 'تم تحضير الدرس'};

  static String _topic(Map<String, dynamic> period) {
    final title = _text(period['lesson_title_ar']).isNotEmpty
        ? _text(period['lesson_title_ar'])
        : _text(period['lesson_title']);
    // Titles come as "subject -- lesson"; the sheet wants the lesson.
    final parts = title.split('--');
    final topic = (parts.length > 1 ? parts[1] : title).trim();
    return _placeholders.contains(topic) ? '' : topic;
  }

  static dynamic _decode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static String _text(dynamic value) => value == null ? '' : value.toString().trim();
}

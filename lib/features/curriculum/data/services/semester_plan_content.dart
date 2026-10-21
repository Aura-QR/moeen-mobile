import 'package:moean/core/utils/formatters/localized_digits.dart';
import 'package:moean/core/utils/formatters/text_direction_detector.dart';
import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';

/// Looks up a translation key; `appTranslation().get` in the app.
typedef Translate = String Function(String key);

/// The text of the semester plan, shared by the PDF and the Word export so
/// both print the same words. Digits are Arabic-Indic when [isArabic].
class SemesterPlanContent {
  static const String defaultAcademicYear = '1448';
  static const String _separator = '   |   ';

  final bool isArabic;
  final String title;
  final String subjectLine;
  final String termLine;

  /// Teacher and school; null when neither was entered.
  final String? peopleLine;

  /// Week, date, lessons, notes, in reading order.
  final List<String> headers;
  final List<SemesterPlanRow> rows;
  final String teacherSignature;
  final String principalSignature;

  /// «الخطة الفصلية - {المادة}», without an extension.
  final String fileBaseName;

  const SemesterPlanContent._({
    required this.fileBaseName,
    required this.isArabic,
    required this.title,
    required this.subjectLine,
    required this.termLine,
    required this.peopleLine,
    required this.headers,
    required this.rows,
    required this.teacherSignature,
    required this.principalSignature,
  });

  factory SemesterPlanContent.from(
    CurriculumPlanDetailModel detail, {
    required String school,
    required String teacher,
    required bool isArabic,
    required Translate translate,
  }) {
    final t = translate;
    String digits(String text) => localizeDigits(text, isArabic: isArabic);
    final plan = detail.plan;
    final year = plan.academicYear.isEmpty ? defaultAcademicYear : plan.academicYear;
    final people = [
      if (teacher.isNotEmpty) '${t('semester_plan_teacher_short')}: $teacher',
      if (school.isNotEmpty) '${t('semester_plan_school')}: $school',
    ];
    const dots = '................................';

    return SemesterPlanContent._(
      fileBaseName: '${t('semester_plan_pdf_title')} - ${plan.subjectName}',
      isArabic: isArabic,
      title: '${t('portfolio_pdf_brand')}$_separator${t('semester_plan_pdf_title')}',
      subjectLine: '${t('semester_plan_subject')}: ${plan.subjectName}$_separator${t('semester_plan_grade')}: ${plan.gradeName}',
      termLine: digits('${t('semester_plan_semester')}: ${plan.semester}$_separator${t('semester_plan_year')}: $year'),
      peopleLine: people.isEmpty ? null : people.join(_separator),
      headers: [
        for (final key in ['semester_plan_week', 'semester_plan_date', 'semester_plan_lessons', 'semester_plan_notes'])
          t(key),
      ],
      rows: [for (final week in detail.weeks) SemesterPlanRow._from(week, isArabic: isArabic, translate: t)],
      teacherSignature: '${t('semester_plan_teacher')}: $dots',
      principalSignature: '${t('semester_plan_principal')}: $dots',
    );
  }

  /// `2026-08-23` (or a full timestamp) as `2026/08/23`.
  static String formatDate(String value) {
    final day = value.length >= 10 ? value.substring(0, 10) : value;
    return day.replaceAll('-', '/');
  }
}

class SemesterPlanRow {
  /// A holiday or exam week, printed as one merged row with [breakText].
  final bool isBreak;
  final String breakText;
  final String week;

  /// «من 2026/08/23 إلى» and «2026/08/27», printed on two lines.
  final String dateFirstLine;
  final String dateSecondLine;
  final String lessons;
  final String notes;

  const SemesterPlanRow._({
    required this.isBreak,
    required this.breakText,
    required this.week,
    required this.dateFirstLine,
    required this.dateSecondLine,
    required this.lessons,
    required this.notes,
  });

  factory SemesterPlanRow._from(CurriculumWeekModel week, {required bool isArabic, required Translate translate}) {
    final t = translate;
    String digits(String text) => localizeDigits(text, isArabic: isArabic);
    final from = SemesterPlanContent.formatDate(week.startsOn);
    final to = SemesterPlanContent.formatDate(week.endsOn);
    final isBreak = week.isHoliday || week.isExam;
    final breakTitle = week.title ?? t(week.isHoliday ? 'semester_plan_holiday' : 'semester_plan_exams');

    final lessonTexts = [
      for (final item in week.items) item.unit.isEmpty ? item.title : '${item.unit} — ${item.title}',
    ];
    final lessons = lessonTexts.join(listSeparatorFor(lessonTexts.firstOrNull ?? '', fallbackRtl: isArabic));
    final notes = week.notes.join(listSeparatorFor(week.notes.firstOrNull ?? '', fallbackRtl: isArabic));

    return SemesterPlanRow._(
      isBreak: isBreak,
      breakText: digits('$breakTitle${SemesterPlanContent._separator}${t('semester_plan_from')} $from ${t('semester_plan_to')} $to'),
      week: digits('${week.weekNumber ?? ''}'),
      dateFirstLine: digits('${t('semester_plan_from')} $from ${t('semester_plan_to')}'),
      dateSecondLine: digits(to),
      lessons: lessons.isEmpty ? '—' : lessons,
      notes: notes.isEmpty ? '—' : notes,
    );
  }
}

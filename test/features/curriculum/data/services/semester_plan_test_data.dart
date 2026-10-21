import 'package:moean/features/curriculum/data/models/curriculum_distribution_models.dart';

/// A small plan shaped like a real one: teaching weeks, a holiday with a
/// note-free row, an English lesson week, an empty week and exams.
CurriculumPlanDetailModel samplePlan() => CurriculumPlanDetailModel.fromJson({
      'plan': {
        'id': 1,
        'subject_name': 'الرياضيات',
        'grade_name': 'الصف الأول المتوسط',
        'semester': 1,
        'academic_year': '1448',
      },
      'weeks': [
        {
          'type': 'teaching',
          'week_number': 5,
          'starts_on': '2026-09-20',
          'ends_on': '2026-09-24',
          'notes': ['إجازة اليوم الوطني'],
          'items': [
            {'id': 1, 'title': 'التهيئة', 'unit': 'الأعداد الصحيحة'},
            {'id': 2, 'title': 'القيمة المطلقة', 'unit': 'الأعداد الصحيحة'},
          ],
        },
        {
          'type': 'holiday',
          'title': 'إجازة الخريف',
          'starts_on': '2026-11-22',
          'ends_on': '2026-11-26',
          'items': [],
          'notes': [],
        },
        {
          'type': 'teaching',
          'week_number': 11,
          'starts_on': '2026-11-01',
          'ends_on': '2026-11-05',
          'notes': [],
          'items': [
            {'id': 3, 'title': 'Grammar', 'unit': 'Is There A View?'},
            {'id': 4, 'title': 'Listening & Pronunciation', 'unit': 'Is There A View?'},
          ],
        },
        {'type': 'teaching', 'week_number': 17, 'starts_on': '2026-12-20', 'ends_on': '2026-12-24', 'notes': [], 'items': []},
        {'type': 'exam', 'starts_on': '2027-01-03', 'ends_on': '2027-01-07', 'items': [], 'notes': []},
      ],
    });

/// Returns the key itself, except for the few words the tests read.
String fakeTranslate(String key) => const {
      'semester_plan_from': 'من',
      'semester_plan_to': 'إلى',
      'semester_plan_exams': 'اختبارات',
      'semester_plan_pdf_title': 'الخطة الفصلية',
    }[key] ??
    key;

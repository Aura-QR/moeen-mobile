import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';

void main() {
  const sampleRoles = [
    RoleSuiteSummary(key: 'vice_principal', label: 'وكيل شؤون الطلاب', documentsCount: 14),
    RoleSuiteSummary(key: 'activity_leader', label: 'رائد النشاط', documentsCount: 16),
    RoleSuiteSummary(key: 'health_guide', label: 'الموجه الصحي', documentsCount: 12),
    RoleSuiteSummary(key: 'student_counsellor', label: 'الموجه الطلابي', documentsCount: 18),
  ];

  test('parseRoleSuitesList supports both bare list and {roles: [...]} map', () {
    final fromList = parseRoleSuitesList([
      {'key': 'activity_leader', 'label': 'رائد النشاط', 'documents_count': 16},
    ]);
    final fromMap = parseRoleSuitesList({
      'roles': [
        {'key': 'health_guide', 'label': 'الموجه الصحي', 'documents_count': 12},
      ],
    });
    expect(fromList.single.key, 'activity_leader');
    expect(fromList.single.documentsCount, 16);
    expect(fromMap.single.key, 'health_guide');
    expect(fromMap.single.documentsCount, 12);
  });

  test('roleSuiteKeyForPortfolioRole maps portfolio roles including student_counselor spelling', () {
    expect(roleSuiteKeyForPortfolioRole('activity_leader'), 'activity_leader');
    expect(roleSuiteKeyForPortfolioRole('health_guide'), 'health_guide');
    expect(roleSuiteKeyForPortfolioRole('student_counselor'), 'student_counsellor');
    expect(roleSuiteKeyForPortfolioRole('student_counsellor'), 'student_counsellor');
    expect(roleSuiteKeyForPortfolioRole('teacher'), isNull);
  });

  test('sortRolesByPortfolio moves the matched role card first and keeps the rest in order', () {
    final sorted = sortRolesByPortfolio(sampleRoles, ['teacher', 'student_counselor']);
    expect(sorted.map((r) => r.key).toList(), [
      'student_counsellor',
      'vice_principal',
      'activity_leader',
      'health_guide',
    ]);
    expect(matchedRoleSuiteKey(sampleRoles, ['teacher', 'student_counselor']), 'student_counsellor');
  });

  test('RoleSuiteDetailModel and RoleDocumentTemplateModel parse all flags and metadata', () {
    final detail = RoleSuiteDetailModel.fromJson({
      'key': 'health_guide',
      'label': 'الموجه الصحي',
      'categories': [
        {
          'key': 'records',
          'label': 'السجلات والنماذج',
          'documents': [
            {'key': 'clinic_visit', 'label': 'سجل التردد على العيادة', 'ai': false, 'sensitive': true},
            {'key': 'awareness_report', 'label': 'تقرير برنامج توعوي', 'ai': true, 'sensitive': false},
          ],
        },
      ],
    });
    expect(detail.categories.single.documents, hasLength(2));
    expect(detail.categories.single.documents.first.sensitive, isTrue);
    expect(detail.categories.single.documents.last.ai, isTrue);

    final template = RoleDocumentTemplateModel.fromJson(
      {
        'type': 'report',
        'label': 'الخطة الفصلية',
        'ai': true,
        'brief_hint': 'اكتب محور البرنامج الصحي...',
        'sensitive': false,
        'names_column': 1,
        'element': 'duties',
        'term': 'first',
        'region': 'riyadh',
        'input': {
          'title': 'الخطة الفصلية للموجه الصحي',
          'blocks': [
            {'kind': 'heading', 'text': 'الأهداف'},
          ],
        },
      },
      fallbackRole: 'health_guide',
      fallbackDoc: 'term_plan',
    );
    expect(template.role, 'health_guide');
    expect(template.doc, 'term_plan');
    expect(template.ai, isTrue);
    expect(template.briefHint, 'اكتب محور البرنامج الصحي...');
    expect(template.namesColumn, 1);
    expect(template.element, 'duties');
    expect(template.term, 'first');
    expect(template.region, 'riyadh');
  });
}

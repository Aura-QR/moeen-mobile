import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/documents/data/models/ai_job_model.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/data/models/plan_catalogue_model.dart';
import 'package:moean/features/documents/data/models/plan_form_input.dart';

void main() {
  group('PlanCatalogueModel', () {
    test('reads the remedial sections and improvement levels', () {
      final catalogue = PlanCatalogueModel.fromJson(const {
        'sections': [
          {'key': 'weaknesses', 'label': 'نقاط الضعف', 'options': ['أ']},
        ],
        'improvement': {'label': 'مستوى التحسن', 'options': ['جيد', 'محدود']},
      });

      expect(catalogue.sections.single.key, 'weaknesses');
      expect(catalogue.improvementLabel, 'مستوى التحسن');
      expect(catalogue.improvementOptions, ['جيد', 'محدود']);
      expect(catalogue.targetGroups, isEmpty);
    });

    test('reads the enrichment target groups', () {
      final catalogue = PlanCatalogueModel.fromJson(const {
        'sections': [],
        'target_groups': ['المتفوقون', 'الموهوبون'],
      });

      expect(catalogue.targetGroups, ['المتفوقون', 'الموهوبون']);
    });
  });

  group('AiJobModel', () {
    test('reads a done job with its lists', () {
      final job = AiJobModel.fromJson(const {
        'id': 51,
        'kind': 'remedial_suggestions',
        'status': 'done',
        'result': {
          'weaknesses': ['أ'],
          'methods': ['ب', 'ج'],
        },
        'error': null,
      });

      expect(job.isDone, isTrue);
      expect(job.result, {
        'weaknesses': ['أ'],
        'methods': ['ب', 'ج'],
      });
      expect(job.error, isNull);
    });

    test('a pending job has no result', () {
      final job = AiJobModel.fromJson(const {'id': '7', 'status': 'pending', 'result': null});

      expect(job.id, 7);
      expect(job.isPending, isTrue);
      expect(job.result, isEmpty);
    });
  });

  group('PlanFormInput', () {
    final saved = <String, dynamic>{
      'plan_type': 'linked',
      'lesson_ids': [12, '13'],
      'subject': ' رياضيات ',
      'class_name': 'خامس 1',
      'date': '2026-10-22',
      'class_id': 3,
      'students': ['سارة', ' ', 'أحمد'],
      'weaknesses': ['أ', 'ب'],
      'methods': [],
      'improvement': 'جيد',
      'academic_year': '1448 هـ',
      'date_hijri': '30-04-1448',
      'theme': 'blue',
      'header': {'school_name': 'الأمل', 'principal_name': null},
      'images': ['documents/1/uploads/a.jpg'],
    };

    test('reads the saved input, keeping unknown fields aside', () {
      final input = PlanFormInput.fromJson(saved, sectionKeys: const ['weaknesses', 'methods', 'actions']);

      expect(input.planType, PlanFormInput.linked);
      expect(input.lessonIds, [12, 13]);
      expect(input.subject, 'رياضيات');
      expect(input.date, DateTime(2026, 10, 22));
      expect(input.classId, 3);
      expect(input.students, ['سارة', 'أحمد']);
      expect(input.sections, {
        'weaknesses': ['أ', 'ب'],
        'methods': <String>[],
        'actions': <String>[],
      });
      expect(input.improvement, 'جيد');
      expect(input.theme, DocumentTheme.blue);
      expect(input.header, {'school_name': 'الأمل'});
      expect(input.extra, {'academic_year': '1448 هـ', 'date_hijri': '30-04-1448'});
    });

    test('toJson sends it back, with the extra fields and without empty ones', () {
      final input = PlanFormInput.fromJson(saved, sectionKeys: const ['weaknesses', 'methods']);
      final json = input.toJson();

      expect(json['academic_year'], '1448 هـ');
      expect(json['lesson_ids'], [12, 13]);
      expect(json['date'], '2026-10-22');
      expect(json['weaknesses'], ['أ', 'ب']);
      expect(json.containsKey('grade'), isFalse);
      expect(json.containsKey('target_groups'), isFalse);
    });

    test('an enrichment plan sends no plan type, and no lessons when none are picked', () {
      final json = const PlanFormInput(targetGroups: ['المتفوقون']).toJson();

      expect(json.containsKey('plan_type'), isFalse);
      expect(json.containsKey('lesson_ids'), isFalse);
      expect(json['target_groups'], ['المتفوقون']);
      expect(json['students'], isEmpty);
    });
  });

  test('DocumentModel reads the printed meta rows', () {
    final document = DocumentModel.fromJson(const {
      'id': 9,
      'type': 'remedial_plan',
      'status': 'draft',
      'definition': {
        'meta': [
          {'label': 'الدروس', 'value': 'الكسور، الأعداد العشرية'},
          {'label': 'الفصل', 'value': 'خامس 1'},
        ],
      },
    });

    expect(document.meta, {'الدروس': 'الكسور، الأعداد العشرية', 'الفصل': 'خامس 1'});
  });
}

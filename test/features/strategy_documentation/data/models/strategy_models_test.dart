import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_documentation_input.dart';
import 'package:moean/features/strategy_documentation/data/models/strategy_models.dart';

final _catalogue = StrategyCatalogueModel.fromJson({
  'categories': [
    {'key': 'cooperative', 'label': 'التعلم التعاوني والأقران'},
    {'key': 'thinking', 'label': 'التفكير والاستقصاء'},
    {'key': 'models', 'label': 'نماذج ومداخل تدريسية'},
  ],
  'items': [
    {'key': 'jigsaw', 'name': 'جيكسو (التعلم بالتجزئة)', 'category': 'cooperative'},
    {'key': 'think_pair_share', 'name': 'فكر - زاوج - شارك', 'category': 'cooperative'},
    {'key': 'brainstorming', 'name': 'العصف الذهني', 'category': 'thinking'},
  ],
});

void main() {
  group('StrategyCatalogueModel.grouped', () {
    test('keeps category order and leaves out empty categories', () {
      final groups = _catalogue.grouped('');

      expect(groups.map((g) => g.$1.key), ['cooperative', 'thinking']);
      expect(groups.first.$2.map((s) => s.key), ['jigsaw', 'think_pair_share']);
    });

    test('filters by name', () {
      final groups = _catalogue.grouped(' العصف ');

      expect(groups.single.$1.key, 'thinking');
      expect(groups.single.$2.single.key, 'brainstorming');
    });
  });

  test('StrategyDetailsModel reads the four lists', () {
    final details = StrategyDetailsModel.fromJson({
      'key': 'jigsaw',
      'name': 'جيكسو',
      'definition': 'تعريف',
      'steps': ['أ', 'ب'],
      'teacher_role': ['ج'],
      'student_role': [],
      'outcomes': ['د'],
    });

    expect(details.lists[StrategyListSection.steps], ['أ', 'ب']);
    expect(details.lists[StrategyListSection.studentRole], isEmpty);
  });

  group('StrategyDocumentationInput', () {
    test('toJson leaves out empty fields and keeps unknown ones', () {
      final json = StrategyDocumentationInput(
        strategyKey: 'jigsaw',
        lessonTitle: 'دورة الماء',
        lessonId: 55,
        studentsCount: 28,
        executionDate: DateTime(2026, 9, 3),
        lists: const {StrategyListSection.steps: ['أ'], StrategyListSection.outcomes: []},
        theme: DocumentTheme.blue,
        header: const {'school_name': 'الأمل'},
        images: const ['documents/12/uploads/a.jpg'],
        extra: const {'academic_year': '1448 هـ'},
      ).toJson();

      expect(json['strategy_key'], 'jigsaw');
      expect(json.containsKey('subject'), isFalse);
      expect(json['lesson_id'], 55);
      expect(json['students_count'], 28);
      expect(json['execution_date'], '2026-09-03');
      expect(json['content'], {'steps': ['أ']});
      expect(json['theme'], 'blue');
      expect(json['header'], {'school_name': 'الأمل'});
      expect(json['images'], ['documents/12/uploads/a.jpg']);
      expect(json['academic_year'], '1448 هـ');
    });

    test('fromJson round-trips a saved input', () {
      final input = StrategyDocumentationInput.fromJson({
        'strategy_key': 'jigsaw',
        'subject': 'العلوم',
        'lesson_id': 55,
        'lesson_title': 'دورة الماء',
        'students_count': '28',
        'execution_date': '2026-09-03',
        'content': {
          'definition': 'تعريف معدل',
          'teacher_role': ['ج'],
        },
        'theme': 'gray',
        'header': {'school_name': 'الأمل', 'deputy_name': null},
        'images': ['documents/12/uploads/a.jpg'],
        'execution_date_hijri': '09-05-1448',
      });

      expect(input.studentsCount, 28);
      expect(input.executionDate, DateTime(2026, 9, 3));
      expect(input.definition, 'تعريف معدل');
      expect(input.lists[StrategyListSection.teacherRole], ['ج']);
      expect(input.lists.containsKey(StrategyListSection.steps), isFalse);
      expect(input.theme, DocumentTheme.gray);
      expect(input.header, {'school_name': 'الأمل'});
      expect(input.extra, {'execution_date_hijri': '09-05-1448'});
    });
  });
}

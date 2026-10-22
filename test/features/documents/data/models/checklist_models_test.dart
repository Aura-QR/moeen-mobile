import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/documents/data/models/checklist_models.dart';

const _catalogue = ChecklistCatalogueSection(key: 'methods', label: 'أساليب العلاج', options: ['أ', 'ب', 'ج']);

void main() {
  group('ChecklistSection', () {
    test('starts from the ready options, unticked', () {
      final section = ChecklistSection.fromCatalogue(_catalogue);

      expect(section.lines.map((line) => line.text), ['أ', 'ب', 'ج']);
      expect(section.checkedTexts, isEmpty);
    });

    test('reopening ticks saved options and brings other saved lines back as custom, ticked', () {
      final section = ChecklistSection.fromCatalogue(_catalogue, saved: const ['ب', 'سطري', 'اقتراح سابق']);

      expect(section.checkedTexts, ['ب', 'سطري', 'اقتراح سابق']);
      expect(section.lines.where((line) => line.isCustom).map((line) => line.text), ['سطري', 'اقتراح سابق']);
    });

    test('the value is only the ticked lines, in order', () {
      final section = ChecklistSection.fromCatalogue(_catalogue).toggle(2).toggle(0);

      expect(section.checkedTexts, ['أ', 'ج']);
      expect(section.toggle(0).checkedTexts, ['ج']);
    });

    test('ticking stops at the limit; unticking still works', () {
      final full = ChecklistSection.fromCatalogue(_catalogue, maxChecked: 2).toggle(0).toggle(1);

      expect(identical(full.toggle(2), full), isTrue);
      expect(full.isFull, isTrue);
      expect(full.toggle(0).checkedTexts, ['ب']);
    });

    test('a custom line is added ticked; an existing line is ticked instead', () {
      final section = ChecklistSection.fromCatalogue(_catalogue).addCustom('  سطري  ').addCustom('ب');

      expect(section.lines.length, 4);
      expect(section.lines.last.isCustom, isTrue);
      expect(section.checkedTexts, ['ب', 'سطري']);
    });

    test('only custom lines can be edited and removed; clearing removes', () {
      var section = ChecklistSection.fromCatalogue(_catalogue).addCustom('سطري');

      expect(identical(section.editCustom(0, 'تغيير'), section), isTrue);
      expect(identical(section.removeCustom(0), section), isTrue);

      section = section.editCustom(3, 'سطري المعدل');
      expect(section.lines[3].text, 'سطري المعدل');
      expect(section.lines[3].isChecked, isTrue);
      expect(section.editCustom(3, '  ').lines.length, 3);
    });

    test('suggestions join unticked, skipping lines already there', () {
      final section = ChecklistSection.fromCatalogue(_catalogue).toggle(0).addSuggestions(const ['أ', 'جديد', 'جديد', ' ']);

      expect(section.lines.map((line) => line.text), ['أ', 'ب', 'ج', 'جديد']);
      expect(section.lines.last.origin, ChecklistOrigin.suggested);
      expect(section.lines.last.isChecked, isFalse);
      expect(section.checkedTexts, ['أ']);
    });

    test('nothing new to suggest returns the same section', () {
      final section = ChecklistSection.fromCatalogue(_catalogue);

      expect(identical(section.addSuggestions(const ['أ']), section), isTrue);
    });

    test('lines are clipped to the length limit', () {
      final section = ChecklistSection.fromCatalogue(_catalogue, maxLength: 3).addCustom('سطر طويل');

      expect(section.lines.last.text, 'سطر');
    });
  });

  test('ChecklistCatalogueSection reads key, label and options', () {
    final section = ChecklistCatalogueSection.fromJson(const {
      'key': 'weaknesses',
      'label': 'نقاط الضعف',
      'options': ['أ', 'ب'],
    });

    expect(section.key, 'weaknesses');
    expect(section.label, 'نقاط الضعف');
    expect(section.options, ['أ', 'ب']);
  });
}

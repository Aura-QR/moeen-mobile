import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';

void main() {
  group('SchoolClassModel', () {
    test('reads a list item without names', () {
      final schoolClass = SchoolClassModel.fromJson(const {
        'id': 3,
        'name': 'خامس 1',
        'grade': 'الخامس',
        'subject': null,
        'students_count': 28,
        'updated_at': '2026-10-22T08:00:00+00:00',
      });

      expect(schoolClass.id, 3);
      expect(schoolClass.subject, '');
      expect(schoolClass.studentsCount, 28);
      expect(schoolClass.students, isEmpty);
      expect(schoolClass.updatedAt, isNotNull);
    });

    test('reads the names in order and counts them without students_count', () {
      final schoolClass = SchoolClassModel.fromJson(const {
        'id': '4',
        'name': 'خامس 2',
        'students': [
          {'id': 1, 'name': 'سارة'},
          {'id': 2, 'name': 'أحمد'},
        ],
      });

      expect(schoolClass.id, 4);
      expect(schoolClass.students, ['سارة', 'أحمد']);
      expect(schoolClass.studentsCount, 2);
    });

    test('toJson sends the whole list, and empty details as null', () {
      const schoolClass = SchoolClassModel(name: 'خامس 1', students: ['أحمد', 'سارة']);

      expect(schoolClass.toJson(), {
        'name': 'خامس 1',
        'grade': null,
        'subject': null,
        'students': ['أحمد', 'سارة'],
      });
    });
  });
}

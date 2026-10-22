import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/classes/data/utils/student_names.dart';

void main() {
  group('splitStudentNames', () {
    test('splits one name per line and trims spaces', () {
      expect(splitStudentNames('  أحمد علي \nسارة محمد\r\nخالد'), ['أحمد علي', 'سارة محمد', 'خالد']);
    });

    test('drops empty lines', () {
      expect(splitStudentNames('أحمد\n\n   \nسارة\n'), ['أحمد', 'سارة']);
    });

    test('drops Latin and Arabic numbering', () {
      expect(splitStudentNames('1. أحمد\n٢- سارة\n3) خالد\n4 ـ ليان\n5: نورة'), ['أحمد', 'سارة', 'خالد', 'ليان', 'نورة']);
    });

    test('keeps digits that are part of a name, and duplicates', () {
      expect(splitStudentNames('محمد 2\nمحمد 2'), ['محمد 2', 'محمد 2']);
    });

    test('empty text gives no names', () {
      expect(splitStudentNames(''), isEmpty);
    });
  });
}

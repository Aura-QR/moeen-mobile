import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';

void main() {
  group('parseGrade', () {
    test('reads Latin and Arabic digits, with a point or a comma', () {
      expect(parseGrade('15'), 15);
      expect(parseGrade(' 15.5 '), 15.5);
      expect(parseGrade('١٥٫٥'), 15.5);
      expect(parseGrade('15,5'), 15.5);
    });

    test('empty or not a number is null', () {
      expect(parseGrade(''), isNull);
      expect(parseGrade('غائب'), isNull);
    });
  });

  test('formatGrade drops a trailing .0 and keeps two decimals', () {
    expect(formatGrade(15.0), '15');
    expect(formatGrade(15.5), '15.5');
    expect(formatGrade(14.2727), '14.27');
  });

  test('gradeLines drops blank lines', () {
    expect(gradeLines('18\n\n 15 \r\n12'), ['18', '15', '12']);
  });

  group('gradeError', () {
    test('empty means absent', () => expect(gradeError('', 20), isNull));

    test('above the total or not a number is an error', () {
      expect(gradeError('21', 20), 'grades_error_above_total');
      expect(gradeError('abc', 20), 'grades_error_not_number');
      expect(gradeError('20', 20), isNull);
    });

    test('without a total only the number is checked', () => expect(gradeError('99', null), isNull));
  });
}

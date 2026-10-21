import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/utils/formatters/text_direction_detector.dart';

void main() {
  test('Arabic first is right to left', () {
    expect(isRtlText('الجبر — Grammar', fallback: false), isTrue);
  });

  test('Latin first is left to right, even with Arabic later', () {
    expect(isRtlText('Is There A View? — مراجعة', fallback: true), isFalse);
  });

  test('no letters falls back', () {
    expect(isRtlText('— 12', fallback: true), isTrue);
    expect(isRtlText('', fallback: false), isFalse);
  });

  test('listSeparatorFor follows the text', () {
    expect(listSeparatorFor('Grammar', fallbackRtl: true), ', ');
    expect(listSeparatorFor('التهيئة', fallbackRtl: false), '، ');
  });
}

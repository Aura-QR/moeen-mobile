import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';

void main() {
  test('isoDate pads month and day', () {
    expect(isoDate(DateTime(2026, 9, 3)), '2026-09-03');
    expect(isoDate(DateTime(2026, 12, 25, 18, 30)), '2026-12-25');
  });
}

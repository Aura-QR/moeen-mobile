import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/performance/presentation/performance_format.dart';

void main() {
  test('formatScore drops trailing zeros', () {
    expect(formatScore(13), '13');
    expect(formatScore(10), '10');
    expect(formatScore(4.3), '4.3');
    expect(formatScore(4.333), '4.33');
    expect(formatScore(86.7), '86.7');
  });
}

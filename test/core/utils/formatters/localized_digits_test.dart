import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/utils/formatters/localized_digits.dart';

void main() {
  test('Arabic uses Arabic-Indic digits', () {
    expect(localizeDigits('2026/08/23 - 1448', isArabic: true), '٢٠٢٦/٠٨/٢٣ - ١٤٤٨');
  });

  test('English keeps the digits', () {
    expect(localizeDigits('2026/08/23', isArabic: false), '2026/08/23');
  });

  test('non-digit text is untouched', () {
    expect(localizeDigits('الصف الأول', isArabic: true), 'الصف الأول');
  });

  test('latinDigits turns typed Arabic-Indic digits into 0-9', () {
    expect(latinDigits('٢٨'), '28');
    expect(latinDigits('٥/١'), '5/1');
    expect(latinDigits('28'), '28');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:moean/core/utils/constants/translations.dart';
import 'package:moean/features/qr_codes/data/utils/format_bytes.dart';

void main() {
  group('formatBytes', () {
    final translations = TranslationModel.fromJson({
      'qr_unit_kb': 'كيلوبايت',
      'qr_unit_mb': 'ميجابايت',
      'qr_unit_gb': 'جيجابايت',
    });

    test('formats KB values properly', () {
      expect(formatBytes(1024, translations), '1 كيلوبايت');
      expect(formatBytes(2048, translations), '2 كيلوبايت');
      expect(formatBytes(1536, translations), '1.5 كيلوبايت');
    });

    test('formats MB values properly', () {
      expect(formatBytes(1024 * 1024, translations), '1 ميجابايت');
      expect(formatBytes(50 * 1024 * 1024, translations), '50 ميجابايت');
      expect(
        formatBytes((2.5 * 1024 * 1024).toInt(), translations),
        '2.5 ميجابايت',
      );
    });

    test('formats GB values properly', () {
      expect(formatBytes(1024 * 1024 * 1024, translations), '1 جيجابايت');
      expect(formatBytes(2 * 1024 * 1024 * 1024, translations), '2 جيجابايت');
    });
  });
}

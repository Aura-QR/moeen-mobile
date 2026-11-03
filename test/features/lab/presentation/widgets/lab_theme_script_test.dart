import 'package:flutter_test/flutter_test.dart';
import 'package:moean/features/lab/presentation/widgets/lab_theme_script.dart';

void main() {
  group('buildLabThemeScript', () {
    test('produces dark mode script with dark theme and class addition', () {
      final script = buildLabThemeScript(true);
      expect(script, contains("var t = 'dark'"));
      expect(script, contains("localStorage.setItem('hadr-theme', t)"));
      expect(script, contains("classList.add('dark')"));
    });

    test('produces light mode script with light theme and class removal', () {
      final script = buildLabThemeScript(false);
      expect(script, contains("var t = 'light'"));
      expect(script, contains("localStorage.setItem('hadr-theme', t)"));
      expect(script, contains("classList.remove('dark')"));
    });
  });
}

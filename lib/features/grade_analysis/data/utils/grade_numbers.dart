import 'package:moean/core/utils/formatters/localized_digits.dart';

/// A typed grade or mark: Arabic digits and a decimal comma are read
/// (١٥٫٥ is 15.5). Null when empty or not a number.
double? parseGrade(String text) {
  final value = latinDigits(text.trim()).replaceAll(RegExp('[٫,]'), '.');
  if (value.isEmpty) return null;
  return double.tryParse(value);
}

/// A number as the teacher would write it: 15, 15.5, 14.27.
String formatGrade(num value) {
  final rounded = (value * 100).round() / 100;
  return rounded == rounded.truncateToDouble() ? rounded.toInt().toString() : '$rounded';
}

/// «إدخال الدرجات فقط»: one grade per line, blank lines dropped.
List<String> gradeLines(String text) =>
    text.split(RegExp(r'\r?\n')).map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

/// Why [text] can't be a grade out of [total], as a translation key, or null.
/// Empty is fine: it means «غائب».
String? gradeError(String text, double? total) {
  if (text.trim().isEmpty) return null;
  final grade = parseGrade(text);
  if (grade == null || grade < 0) return 'grades_error_not_number';
  if (total != null && grade > total) return 'grades_error_above_total';
  return null;
}

import 'package:flutter/foundation.dart';

/// Available variable symbols in order (1..5).
const List<String> kLabVariableSymbols = ['a', 'b', 'c', 'd', 'e'];

/// Converts Arabic-Indic digits (`٠-٩`, `۰-۹`) to ASCII digits.
String normalizeLabDigits(String input) {
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  const easternArabic = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final idx1 = arabicIndic.indexOf(ch);
    if (idx1 != -1) {
      buffer.write(idx1);
      continue;
    }
    final idx2 = easternArabic.indexOf(ch);
    if (idx2 != -1) {
      buffer.write(idx2);
      continue;
    }
    if (ch == '٫' || ch == ',') {
      buffer.write('.');
      continue;
    }
    buffer.write(ch);
  }
  return buffer.toString();
}

/// Parses a number from user input (supporting Arabic digits).
num parseLabNumber(String raw, {required num fallback}) {
  final normalized = normalizeLabDigits(raw).trim();
  return num.tryParse(normalized) ?? fallback;
}

/// Normalizes UI math symbols (`×`, `÷`, `√`, Arabic digits) into backend formula syntax.
String normalizeLabFormula(String raw) {
  var result = normalizeLabDigits(raw).trim();
  result = result.replaceAll('×', '*').replaceAll('÷', '/');
  result = result.replaceAll('√(', 'sqrt(');
  result = result.replaceAllMapped(
    RegExp(r'√\s*([a-zA-Z0-9_.]+)'),
    (m) => 'sqrt(${m.group(1)})',
  );
  result = result.replaceAll('√', 'sqrt');
  return result;
}

/// Variable definition for `POST /lab/experiments` (`LAB_API.md` §2.3).
@immutable
class LabVariableInput {
  final String symbol;
  final String label;
  final String unit;
  final num min;
  final num max;
  final num? defaultValue;

  const LabVariableInput({
    required this.symbol,
    required this.label,
    this.unit = '',
    required this.min,
    required this.max,
    this.defaultValue,
  });

  num get resolvedDefault {
    final mid = (min + max) / 2;
    final candidate = defaultValue ?? mid;
    if (candidate < min || candidate > max) return mid;
    return candidate;
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'label': label.trim(),
        'unit': unit.trim(),
        'min': min,
        'max': max,
        'default': resolvedDefault,
      };
}

/// Reading formula definition for `POST /lab/experiments` (`LAB_API.md` §2.3).
@immutable
class LabReadingInput {
  final String label;
  final String unit;
  final String formula;

  const LabReadingInput({
    required this.label,
    this.unit = '',
    required this.formula,
  });

  String get normalizedFormula => normalizeLabFormula(formula);

  Map<String, dynamic> toJson() => {
        'label': label.trim(),
        'unit': unit.trim(),
        'formula': normalizedFormula,
      };
}

/// Request payload for `POST /lab/experiments` (`LAB_API.md` §2.3).
@immutable
class LabCreateExperimentInput {
  final String name;
  final String display;
  final String? about;
  final String? observe;
  final int? lessonId;
  final List<LabVariableInput> variables;
  final List<LabReadingInput> readings;

  const LabCreateExperimentInput({
    required this.name,
    this.display = 'bars',
    this.about,
    this.observe,
    this.lessonId,
    required this.variables,
    required this.readings,
  });

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'display': display,
        if (about != null && about!.trim().isNotEmpty) 'about': about!.trim(),
        if (observe != null && observe!.trim().isNotEmpty)
          'observe': observe!.trim(),
        if (lessonId != null && lessonId! > 0) 'lesson_id': lessonId,
        'variables': variables.map((v) => v.toJson()).toList(),
        'readings': readings.map((r) => r.toJson()).toList(),
      };
}

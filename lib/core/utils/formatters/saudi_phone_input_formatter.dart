import 'package:flutter/services.dart';

/// Formatter to normalize Saudi phone numbers in real-time.
/// - Converts Arabic-Indic and Eastern-Arabic numerals to English ASCII digits.
/// - Strips whitespace, hyphens, and any non-digit characters.
/// - Normalizes international prefixes (+966, 00966, 966) if pasted.
/// - Enforces maximum length of 10 digits (e.g. 05XXXXXXXX).
class SaudiPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final normalized = normalizePhoneNumber(newValue.text);
    final truncated =
        normalized.length > 10 ? normalized.substring(0, 10) : normalized;

    // Calculate cursor position after formatting
    int newOffset = truncated.length;
    if (newValue.selection.end <= newValue.text.length) {
      final textBeforeCursor =
          newValue.text.substring(0, newValue.selection.end);
      final normalizedBefore = normalizePhoneNumber(textBeforeCursor);
      newOffset = normalizedBefore.length.clamp(0, truncated.length);
    }

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Utility method to convert Arabic numerals and strip invalid chars
  static String normalizePhoneNumber(String input) {
    if (input.isEmpty) return input;

    // Arabic-Indic & Eastern-Arabic digits mapping
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const easternArabicDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    String normalized = input;
    for (int i = 0; i < 10; i++) {
      normalized = normalized.replaceAll(arabicDigits[i], i.toString());
      normalized = normalized.replaceAll(easternArabicDigits[i], i.toString());
    }

    // Strip all non-digit characters (spaces, dashes, parentheses, +, etc.)
    normalized = normalized.replaceAll(RegExp(r'\D'), '');

    // Handle country codes (+966 / 00966 / 966)
    if (normalized.startsWith('00966')) {
      normalized = normalized.substring(5);
      if (!normalized.startsWith('0')) {
        normalized = '0$normalized';
      }
    } else if (normalized.startsWith('966')) {
      normalized = normalized.substring(3);
      if (!normalized.startsWith('0')) {
        normalized = '0$normalized';
      }
    }

    return normalized;
  }
}

final _strongArabic = RegExp(r'[؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]');
final _strongLatin = RegExp('[A-Za-z]');

/// Whether [text] reads right to left, judged by its first strong letter
/// (like HTML's `dir="auto"`). Returns [fallback] when it has no letters.
bool isRtlText(String text, {required bool fallback}) {
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    if (_strongArabic.hasMatch(char)) return true;
    if (_strongLatin.hasMatch(char)) return false;
  }
  return fallback;
}

/// `، ` for right-to-left lists, `, ` for left-to-right ones.
String listSeparatorFor(String text, {required bool fallbackRtl}) =>
    isRtlText(text, fallback: fallbackRtl) ? '، ' : ', ';

const _arabicIndicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// Writes 0-9 as Arabic-Indic digits (٠-٩) when [isArabic], as printed
/// documents do in Arabic; leaves the text unchanged otherwise.
String localizeDigits(String text, {required bool isArabic}) {
  if (!isArabic) return text;
  return text.replaceAllMapped(RegExp('[0-9]'), (m) => _arabicIndicDigits[int.parse(m[0]!)]);
}

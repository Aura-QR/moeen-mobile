/// A score without trailing zeros: 13.0 → «13», 4.30 → «4.3», 4.333 → «4.33».
String formatScore(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

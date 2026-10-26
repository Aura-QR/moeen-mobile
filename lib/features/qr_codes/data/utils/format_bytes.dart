import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/translations.dart';

String formatBytes(int bytes, [TranslationModel? translations]) {
  final t = translations ?? appTranslation();
  if (bytes < 1024 * 1024) {
    final kb = bytes / 1024;
    final formatted = kb == kb.roundToDouble()
        ? kb.toInt().toString()
        : kb.toStringAsFixed(1);
    return '$formatted ${t.get('qr_unit_kb')}';
  } else if (bytes < 1024 * 1024 * 1024) {
    final mb = bytes / (1024 * 1024);
    final formatted = mb == mb.roundToDouble()
        ? mb.toInt().toString()
        : mb.toStringAsFixed(1);
    return '$formatted ${t.get('qr_unit_mb')}';
  } else {
    final gb = bytes / (1024 * 1024 * 1024);
    final formatted = gb == gb.roundToDouble()
        ? gb.toInt().toString()
        : gb.toStringAsFixed(1);
    return '$formatted ${t.get('qr_unit_gb')}';
  }
}

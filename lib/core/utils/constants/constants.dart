import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/translations.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

TranslationModel appTranslation() =>
    themeCubit.translationModel ?? TranslationModel.fromJson({});

String? token;

// Future<void> launchInBrowser(Uri url) async {
//   if (!await launchUrl(
//     url,
//     mode: LaunchMode.externalApplication,
//   )) {
//     throw Exception('Could not launch $url');
//   }
// }

String formattedCreatedAt(DateTime createdAt) {
  final date = createdAt.toLocal();
  final formattedDate =
      "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";

  final formattedTime =
      "${date.hour.toString().padLeft(2, '0')}:"
      "${date.minute.toString().padLeft(2, '0')}";

  return "$formattedDate || $formattedTime";
}

InputDecoration helpCenterInputDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: ColorsManager.textPrimary.withValues(alpha: .6),
    ),
    filled: true,
    fillColor: ColorsManager.surfacePrimary,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ColorsManager.textPrimary),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: ColorsManager.textPrimary),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFF2D6CDF)),
    ),
  );
}

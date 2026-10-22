import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';

/// `input.theme`: the document's accent colour.
enum DocumentTheme {
  teal(ColorsManager.documentThemeTeal),
  blue(ColorsManager.documentThemeBlue),
  purple(ColorsManager.documentThemePurple),
  gray(ColorsManager.documentThemeGray);

  const DocumentTheme(this.color);

  final Color color;

  String get labelKey => 'document_theme_$name';

  static DocumentTheme fromJson(dynamic value) =>
      values.where((theme) => theme.name == value).firstOrNull ?? teal;
}

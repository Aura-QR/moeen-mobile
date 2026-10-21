import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

/// Shows a floating snackbar. [message] is a translation key or an API message.
void showPrimarySnackBar(BuildContext context, String message, {bool isError = true}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isError ? ColorsManager.errorColor : ColorsManager.successColor,
        content: Text(
          appTranslation().get(message),
          style: TextStylesManager.medium14.copyWith(color: ColorsManager.white),
        ),
      ),
    );
}

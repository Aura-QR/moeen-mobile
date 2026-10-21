import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/widgets/custom_app_dialog.dart';

/// Asks before a destructive action. Resolves to true on confirm.
Future<bool> showPortfolioConfirmDialog(
  BuildContext context, {
  required String titleKey,
  required String messageKey,
  String confirmKey = 'delete',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => CustomAppDialog(
      title: appTranslation().get(titleKey),
      message: appTranslation().get(messageKey),
      icon: Icons.delete_outline_rounded,
      iconColor: ColorsManager.errorColor,
      cancelText: appTranslation().get('cancel'),
      confirmText: appTranslation().get(confirmKey),
      onConfirm: () => Navigator.pop(dialogContext, true),
    ),
  );
  return confirmed ?? false;
}

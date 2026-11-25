import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/widgets/custom_app_dialog.dart';

/// Asks before an action, a destructive one by default. Resolves to true on
/// confirm.
Future<bool> showPrimaryConfirmDialog(
  BuildContext context, {
  required String titleKey,
  required String messageKey,
  String confirmKey = 'delete',
  IconData icon = Icons.delete_outline_rounded,
  Color? iconColor,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => CustomAppDialog(
      title: appTranslation().get(titleKey),
      message: appTranslation().get(messageKey),
      icon: icon,
      iconColor: iconColor ?? ColorsManager.errorColor,
      cancelText: appTranslation().get('cancel'),
      confirmText: appTranslation().get(confirmKey),
      onConfirm: () => Navigator.pop(dialogContext, true),
    ),
  );
  return confirmed ?? false;
}

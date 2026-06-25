import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorsManager.surfacePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        appTranslation().get('logout'),
        style: TextStylesManager.bold18.copyWith(
          color: ColorsManager.textPrimary,
        ),
      ),
      content: Text(
        appTranslation().get('logout_desc'),
        style: TextStylesManager.regular14.copyWith(
          color: ColorsManager.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            appTranslation().get('return_home'),
            style: TextStylesManager.bold14.copyWith(
              color: ColorsManager.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsManager.errorColor,
            foregroundColor: ColorsManager.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            appTranslation().get('logout'),
            style: TextStylesManager.bold14,
          ),
        ),
      ],
    );
  }
}

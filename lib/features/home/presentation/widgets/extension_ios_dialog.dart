import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// Dialog displayed on iOS to inform the user that mobile extensions
/// are only supported on Android.
class ExtensionIosDialog extends StatelessWidget {
  const ExtensionIosDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ExtensionIosDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorsManager.surfacePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorsManager.primaryColor.withValues(alpha: 0.15),
                      ColorsManager.primaryColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.desktop_mac_rounded,
                  color: ColorsManager.primaryColor,
                  size: 32,
                ),
              ),
              verticalSpace20,

              // Title
              Text(
                appTranslation().get('ext_ios_title'),
                style: TextStylesManager.bold18.copyWith(
                  color: ColorsManager.mainText,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace12,

              // Body
              Text(
                appTranslation().get('ext_ios_body'),
                style: TextStylesManager.regular14.copyWith(
                  color: ColorsManager.secondaryText,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace28,

              // Dismiss button
              PrimaryElevatedButton(
                text: appTranslation().get('ext_ios_ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

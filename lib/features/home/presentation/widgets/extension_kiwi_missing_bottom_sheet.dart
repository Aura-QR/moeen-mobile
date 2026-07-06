import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/home/presentation/cubit/extension_install_cubit.dart';

/// Bottom sheet displayed when Kiwi Browser is not installed on the device.
///
/// Explains the direct APK download flow cleanly using a vertical timeline.
class ExtensionKiwiMissingBottomSheet extends StatelessWidget {
  final ExtensionInstallCubit cubit;

  const ExtensionKiwiMissingBottomSheet({
    super.key,
    required this.cubit,
  });

  static Future<void> show(
    BuildContext context,
    ExtensionInstallCubit cubit,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExtensionKiwiMissingBottomSheet(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium Drag handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: ColorsManager.borderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            verticalSpace24,

            // Magic Header Icon
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorsManager.goldDark.withValues(alpha: 0.1),
                    ),
                  ),
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorsManager.primaryColor,
                          ColorsManager.primaryColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ColorsManager.primaryColor.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace20,

            // Title
            Text(
              appTranslation().get('ext_kiwi_needed_title'),
              style: TextStylesManager.bold22.copyWith(
                color: ColorsManager.mainText,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace10,

            // Subtitle
            Text(
              appTranslation().get('ext_kiwi_needed_body'),
              style: TextStylesManager.regular14.copyWith(
                color: ColorsManager.secondaryText,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace32,

            // Vertical Timeline Steps
            const _VerticalStep(
              icon: Icons.cloud_download_rounded,
              number: '1',
              isLast: false,
              translationKey: 'ext_kiwi_step1',
            ),
            const _VerticalStep(
              icon: Icons.replay_circle_filled_rounded,
              number: '2',
              isLast: true,
              translationKey: 'ext_kiwi_step2',
            ),

            verticalSpace32,

            // Primary CTA — Download APK
            PrimaryElevatedButton(
              text: appTranslation().get('ext_install_kiwi'),
              icon: const Icon(
                Icons.android_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                cubit.downloadQuetta();
              },
            ),
            verticalSpace12,

            // Cancel
            SizedBox(
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: ColorsManager.secondaryText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  appTranslation().get('ext_cancel'),
                  style: TextStylesManager.medium16.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A premium vertical timeline step item.
class _VerticalStep extends StatelessWidget {
  final IconData icon;
  final String number;
  final bool isLast;
  final String translationKey;

  const _VerticalStep({
    required this.icon,
    required this.number,
    required this.isLast,
    required this.translationKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Column
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ColorsManager.surfacePrimary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorsManager.primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  number,
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        horizontalSpace16,

        // Content
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorsManager.primaryColor.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: ColorsManager.primaryColor.withValues(alpha: 0.8),
                  size: 24,
                ),
                horizontalSpace12,
                Expanded(
                  child: Text(
                    appTranslation().get(translationKey),
                    style: TextStylesManager.bold14.copyWith(
                      color: ColorsManager.mainText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/core/utils/constants/routes.dart';

/// Dialog shown when the Madrasati school session has expired AND the silent
/// background refresh has already failed (e.g., the Microsoft refresh token
/// is expired or revoked).
///
/// At this point the user must perform a manual WebView login. This dialog
/// provides a clear CTA to navigate to the Microsoft login screen.
///
/// Note: The automatic silent refresh is now handled transparently by
/// [MadrasatiSessionInterceptor] at the Dio layer — this dialog only appears
/// when that interceptor cannot recover the session automatically.
class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SessionExpiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(0, 10),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_clock_rounded,
                color: Colors.orange,
                size: 36,
              ),
            ),
            verticalSpace20,

            // ── Title ─────────────────────────────────────────────
            Text(
              'انتهت جلسة مدرستي',
              style: TextStylesManager.bold20.copyWith(
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace12,

            // ── Message ───────────────────────────────────────────
            Text(
              'تعذّر تجديد الجلسة تلقائياً.\nيرجى تسجيل الدخول في مدرستي مجدداً للاستمرار.',
              style: TextStylesManager.medium14.copyWith(
                color: ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace24,

            // ── Buttons ───────────────────────────────────────────
            Row(
              children: [
                // Dismiss
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: ColorsManager.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'لاحقاً',
                      style: TextStylesManager.bold14.copyWith(
                        color: ColorsManager.textPrimary,
                      ),
                    ),
                  ),
                ),
                horizontalSpace12,

                // Login
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(Routes.loginMicrosoft);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsManager.primaryAction,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'تسجيل الدخول',
                      style: TextStylesManager.bold14.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

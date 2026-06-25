import 'package:flutter/material.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/services/madrasati_headless_refresh_service.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/login/presentation/screen/microsoft_login_screen.dart';

/// Dialog shown when the Madrasati school session has expired.
/// Offers a "تحديث الجلسة" button that triggers a silent HeadlessWebView refresh,
/// and a "إلغاء" button to dismiss.
class SessionExpiredDialog extends StatefulWidget {
  const SessionExpiredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SessionExpiredDialog(),
    );
  }

  @override
  State<SessionExpiredDialog> createState() => _SessionExpiredDialogState();
}

class _SessionExpiredDialogState extends State<SessionExpiredDialog> {
  bool _isRefreshing = false;
  String? _resultMessage;
  bool? _refreshSuccess;

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
      _resultMessage = null;
    });

    final success =
        await sl<MadrasatiHeadlessRefreshService>().refresh();

    if (!mounted) return;

    if (success) {
      setState(() {
        _isRefreshing = false;
        _refreshSuccess = true;
        _resultMessage = 'تم تحديث الجلسة بنجاح ✅';
      });
      // Close dialog after short delay on success
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pop();
    } else {
      setState(() {
        _isRefreshing = false;
        _refreshSuccess = false;
        _resultMessage =
            'تعذّر تحديث الجلسة تلقائياً.\nيرجى تسجيل الدخول في مدرستي مجدداً.';
      });
    }
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
                Icons.timer_off_rounded,
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
              _resultMessage ??
                  'انتهت صلاحية الجلسة الخاصة بمنصة مدرستي.\nاضغط "تحديث الجلسة" للمتابعة.',
              style: TextStylesManager.medium14.copyWith(
                color: _refreshSuccess == false
                    ? ColorsManager.errorColor
                    : _refreshSuccess == true
                        ? ColorsManager.successColor
                        : ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            verticalSpace24,

            // ── Buttons ───────────────────────────────────────────
            if (!(_refreshSuccess == true)) ...[
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isRefreshing
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: ColorsManager.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStylesManager.bold14.copyWith(
                          color: ColorsManager.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  horizontalSpace12,

                  // Refresh
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isRefreshing ? null : (_refreshSuccess == false ? () {
                        Navigator.of(context).pop();
                        context.push(Routes.loginMicrosoft);
                      } : _onRefresh),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsManager.primaryAction,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isRefreshing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _refreshSuccess == false ? 'تسجيل الدخول' : 'تحديث الجلسة',
                              style: TextStylesManager.bold14.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

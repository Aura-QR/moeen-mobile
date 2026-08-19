import 'package:flutter/material.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class EmailVerificationBanner extends StatefulWidget {
  final bool isEmailVerified;
  final String? email;

  const EmailVerificationBanner({
    super.key,
    required this.isEmailVerified,
    this.email,
  });

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  bool _dismissed = false;
  bool _isResending = false;

  Future<void> _handleResend() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    final result =
        await ApiService.resendEmailVerification(email: widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: ColorsManager.errorColor,
          ),
        );
      },
      (data) {
        final message = data['message'] as String? ??
            appTranslation().get('resend_verification_sent');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: ColorsManager.primaryColor,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmailVerified || _dismissed) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8E7),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF4E3B2),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFC98D14),
              size: 18,
            ),
            horizontalSpace8,
            Expanded(
              child: Text(
                appTranslation().get('email_unverified_banner'),
                style: TextStylesManager.bold12.copyWith(
                  color: const Color(0xFF8A5807),
                ),
              ),
            ),
            InkWell(
              onTap: _isResending ? null : _handleResend,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2AD3B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: _isResending
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        appTranslation().get('resend'),
                        style: TextStylesManager.bold10.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            horizontalSpace4,
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 16,
                color: Color(0xFF8A5807),
              ),
              onPressed: () => setState(() => _dismissed = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

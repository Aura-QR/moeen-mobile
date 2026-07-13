import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final status = args?['status'] as String? ?? 'waiting_verification';
    final from = args?['from'] as String? ?? 'bank';

    final info = _resultInfo(status, from);

    return Scaffold(
      backgroundColor: ColorsManager.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: info.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  info.icon,
                  size: 50,
                  color: info.iconColor,
                ),
              ),
              verticalSpace24,
              Text(
                info.title,
                style: TextStylesManager.bold22.copyWith(
                  color: ColorsManager.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace12,
              Text(
                info.subtitle,
                style: TextStylesManager.regular14.copyWith(
                  color: ColorsManager.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace40,
              PrimaryElevatedButton(
                text: appTranslation().get('pay_go_home') ?? '',
                icon: Icon(Icons.home_outlined, size: 20,
                    color: ColorsManager.white),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, Routes.home, (_) => false),
              ),
              verticalSpace12,
              PrimaryElevatedButton(
                text: appTranslation().get('pay_view_history') ?? '',
                icon: Icon(Icons.history_outlined, size: 20,
                    color: ColorsManager.primaryColor),
                backgroundColor: Colors.transparent,
                borderSide: BorderSide(color: ColorsManager.primaryColor),
                textStyle: TextStylesManager.bold14.copyWith(
                  color: ColorsManager.primaryColor,
                ),
                onPressed: () => Navigator.pushReplacementNamed(
                    context, Routes.paymentHistory),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ResultInfo _resultInfo(String status, String from) {
    switch (status) {
      case 'paid':
        return _ResultInfo(
          icon: Icons.check_circle_rounded,
          iconColor: ColorsManager.successColor,
          iconBgColor: const Color(0xFFDCFCE7),
          title: appTranslation().get('pay_result_paid_title') ?? 'تم الدفع بنجاح',
          subtitle: appTranslation().get('pay_result_paid_subtitle') ??
              'تم تفعيل اشتراكك بنجاح. يمكنك الآن الاستمتاع بجميع المميزات.',
        );
      case 'failed':
      case 'rejected':
        return _ResultInfo(
          icon: Icons.cancel_rounded,
          iconColor: ColorsManager.errorColor,
          iconBgColor: const Color(0xFFFEE2E2),
          title: appTranslation().get('pay_result_failed_title') ?? 'فشل الدفع',
          subtitle: appTranslation().get('pay_result_failed_subtitle') ??
              'حدث خطأ أثناء عملية الدفع. يرجى المحاولة مرة أخرى.',
        );
      default:
        return _ResultInfo(
          icon: Icons.hourglass_top_rounded,
          iconColor: const Color(0xFF854D0E),
          iconBgColor: const Color(0xFFFEF9C3),
          title: from == 'bank'
              ? (appTranslation().get('pay_result_pending_bank_title') ??
                  'بانتظار المراجعة')
              : (appTranslation().get('pay_result_pending_title') ??
                  'قيد المعالجة'),
          subtitle: from == 'bank'
              ? (appTranslation().get('pay_result_pending_bank_subtitle') ??
                  'تم استلام الإيصال وسيتم مراجعته من قِبل الإدارة.')
              : (appTranslation().get('pay_result_pending_subtitle') ??
                  'جاري التحقق من عملية الدفع. سيتم تفعيل الاشتراك تلقائياً.'),
        );
    }
  }
}

class _ResultInfo {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const _ResultInfo({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });
}

import 'package:flutter/material.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_cubit.dart';

/// The small white «اشترك» pill on the trial banner; opens the website's
/// checkout.
class TrialBannerButtonWidget extends StatelessWidget {
  const TrialBannerButtonWidget({
    super.key,
    required this.color,
    required this.isLoading,
  });

  final Color color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : () => sl<WebCheckoutCubit>().openCheckout(),
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.white,
        foregroundColor: color,
        disabledBackgroundColor: ColorsManager.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: const Size(0, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: isLoading
          ? SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Text(
              appTranslation().get('web_checkout_banner_btn'),
              style: TextStylesManager.bold12,
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/payment/presentation/widgets/trial_banner_button_widget.dart';
import 'package:moean/features/payment/presentation/widgets/web_checkout_builder.dart';

/// The coloured strip above a screen with the trial or subscription status.
/// Its button opens the website's checkout; with paying `off` only the text
/// shows.
class TrialBannerBarWidget extends StatelessWidget {
  const TrialBannerBarWidget({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStylesManager.bold13.copyWith(color: ColorsManager.white),
                ),
              ),
              WebCheckoutBuilder(
                builder: (context, isOpening) => Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: TrialBannerButtonWidget(
                    color: color,
                    isLoading: isOpening,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

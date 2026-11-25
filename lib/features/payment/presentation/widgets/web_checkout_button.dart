import 'package:flutter/material.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/features/payment/presentation/cubit/web_checkout_cubit.dart';
import 'package:moean/features/payment/presentation/widgets/web_checkout_builder.dart';

/// «اشترك عبر الموقع»: opens the website's checkout in the browser, signed
/// in. Shows nothing at all when the server has paying `off`.
class WebCheckoutButton extends StatelessWidget {
  const WebCheckoutButton({
    super.key,
    this.padding = EdgeInsets.zero,
    this.height = 48,
    this.radius = 25,
  });

  /// Space around the button; collapses with it when paying is off.
  final EdgeInsetsGeometry padding;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return WebCheckoutBuilder(
      builder: (context, isOpening) => Padding(
        padding: padding,
        child: PrimaryElevatedButton(
          text: appTranslation().get('web_checkout_subscribe_btn'),
          height: height,
          radius: radius,
          isLoading: isOpening,
          icon: Icon(
            Icons.open_in_new_rounded,
            size: 20,
            color: ColorsManager.white,
          ),
          onPressed: () => sl<WebCheckoutCubit>().openCheckout(),
        ),
      ),
    );
  }
}

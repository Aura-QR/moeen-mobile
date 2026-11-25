import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/payment/presentation/widgets/web_checkout_button.dart';

/// The upgrade sheet's body: the limit message, plus a button to subscribe on
/// the website when the server allows it. With paying `off` there is no
/// button and no mention of the website (Apple's rule against pointing to a
/// payment outside the app).
class UpgradePromptLimit extends StatelessWidget {
  const UpgradePromptLimit({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.hourglass_empty_rounded,
          size: 64,
          color: ColorsManager.primaryColor,
        ),
        verticalSpace16,
        Text(
          appTranslation().get('plan_limit_reached'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
          textAlign: TextAlign.center,
        ),
        verticalSpace24,
        const WebCheckoutButton(
          height: 52,
          radius: 24,
          padding: EdgeInsets.only(bottom: 8),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            appTranslation().get('close'),
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.secondaryText),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/primary/upgrade_prompt_limit.dart';
import 'package:moean/features/payment/presentation/widgets/web_checkout_close_on_launch.dart';

/// Shown when a tool refuses because the plan's attempts are used up.
///
/// The app takes no payments itself: with the server's `checkout: "web"` the
/// sheet offers to subscribe on the website, otherwise it states the limit
/// only. It closes once the browser has opened.
class UpgradePromptBottomSheet extends StatelessWidget {
  const UpgradePromptBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const UpgradePromptBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 32,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: const WebCheckoutCloseOnLaunch(child: UpgradePromptLimit()),
    );
  }
}

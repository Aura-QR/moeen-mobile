import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/online_tests/data/models/online_test_models.dart';

class OnlineTestStateBadge extends StatelessWidget {
  final String state;

  const OnlineTestStateBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final open = state == OnlineTestState.open;
    final color = open ? ColorsManager.successColor : ColorsManager.secondaryText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(appTranslation().get('online_tests_state_$state'), style: TextStylesManager.bold12.copyWith(color: color)),
    );
  }
}

/// A small coloured tag («بحاجة لتصحيح», «تأخر», «درجة مقترحة»).
class OnlineTestTag extends StatelessWidget {
  final String text;
  final Color color;

  const OnlineTestTag({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStylesManager.medium10.copyWith(color: color)),
      );
}

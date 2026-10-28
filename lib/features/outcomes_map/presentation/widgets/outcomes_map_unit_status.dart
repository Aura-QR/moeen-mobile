import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_map_editor_cubit.dart';

/// The per-unit AI indicator: spinner while running, ✓ when done, «إعادة» on failure.
class OutcomesMapUnitStatus extends StatelessWidget {
  final UnitAiStatus status;
  final VoidCallback onRetry;

  const OutcomesMapUnitStatus({super.key, required this.status, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case UnitAiStatus.running:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UnitAiStatus.done:
        return Icon(Icons.check_circle_rounded, size: 20, color: ColorsManager.primaryColor);
      case UnitAiStatus.failed:
        return TextButton.icon(
          onPressed: onRetry,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
          icon: Icon(Icons.refresh_rounded, size: 18, color: ColorsManager.errorColor),
          label: Text(
            appTranslation().get('outcomes_map_retry'),
            style: TextStylesManager.bold12.copyWith(color: ColorsManager.errorColor),
          ),
        );
      case UnitAiStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';

/// «لا توجد شواهد» (grey), «شواهد جزئية» (amber) or «مكتمل» (green), with the count.
class PerformanceStateChip extends StatelessWidget {
  final PerformanceEvidenceState state;
  final int count;

  const PerformanceStateChip({super.key, required this.state, required this.count});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      PerformanceEvidenceState.none => ColorsManager.secondaryText,
      PerformanceEvidenceState.some => ColorsManager.statusWarning,
      PerformanceEvidenceState.complete => ColorsManager.successColor,
    };
    final label = appTranslation().get('performance_state_${state.name}');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(
        count == 0 ? label : '$label · ${appTranslation().get('performance_evidence_count').replaceAll('{n}', '$count')}',
        style: TextStylesManager.medium12.copyWith(color: color),
      ),
    );
  }
}

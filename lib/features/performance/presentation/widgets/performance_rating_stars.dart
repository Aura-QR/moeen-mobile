import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';

/// 1–[max] stars. Read-only when [onRate] is null.
class PerformanceRatingStars extends StatelessWidget {
  final int? rating;
  final int max;
  final ValueChanged<int>? onRate;
  final double size;

  const PerformanceRatingStars({super.key, required this.rating, required this.max, this.onRate, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var value = 1; value <= max; value++)
          InkResponse(
            onTap: onRate == null ? null : () => onRate!(value),
            radius: size,
            child: Padding(
              padding: EdgeInsets.all(onRate == null ? 0 : 4),
              child: Icon(
                value <= (rating ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                size: size,
                color: value <= (rating ?? 0) ? ColorsManager.statusWarning : ColorsManager.borderLightGray,
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

class PortfolioCompletionRingWidget extends StatelessWidget {
  final int percent;
  final double size;

  const PortfolioCompletionRingWidget({super.key, required this.percent, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final color = percent >= 100 ? ColorsManager.successColor : ColorsManager.primaryColor;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: (percent / 100).clamp(0.0, 1.0),
            strokeWidth: size / 9,
            strokeCap: StrokeCap.round,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          Center(
            child: Text(
              '$percent%',
              style: (size >= 64 ? TextStylesManager.bold16 : TextStylesManager.bold12)
                  .copyWith(color: ColorsManager.mainText),
            ),
          ),
        ],
      ),
    );
  }
}

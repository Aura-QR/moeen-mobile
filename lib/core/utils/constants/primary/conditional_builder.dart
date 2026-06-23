import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/primary/circle_indecator.dart';

class ConditionalBuilder extends StatelessWidget {
  final bool loadingState;
  final bool errorState;
  final bool emptyState;

  final WidgetBuilder successBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? errorBuilder;
  final WidgetBuilder? emptyBuilder;

  const ConditionalBuilder({
    super.key,
    required this.loadingState,
    this.errorState = false,
    this.emptyState = false,
    required this.successBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (loadingState) {
      return loadingBuilder?.call(context) ??
          const Center(child: DiscreteCircle(
                          size: 60,
                          color:Color(0xFFD61F69),
                          secondCircleColor:Color(0xFFE2AD3B),
                          thirdCircleColor:Color(0xFF0E7A5E)
                        ),);
    }

    if (errorState) {
      return errorBuilder?.call(context) ?? const SizedBox.shrink();
    }

    if (emptyState) {
      return emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }

    return successBuilder(context);
  }
}

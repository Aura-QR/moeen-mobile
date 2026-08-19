import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';

class SuspendedHeaderShieldIconWidget extends StatelessWidget {
  const SuspendedHeaderShieldIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: ColorsManager.suspendedIconBg,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.gpp_maybe_outlined,
          color: ColorsManager.errorColor,
          size: 36,
        ),
      ),
    );
  }
}

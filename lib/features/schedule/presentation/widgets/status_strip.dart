import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/widgets/status_item_widget.dart';

class StatusStrip extends StatelessWidget {
  const StatusStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StatusItemWidget(status: ClassStatus.waiting, titleKey: 'status_waiting'),
          horizontalSpace16,
          StatusItemWidget(status: ClassStatus.prepared, titleKey: 'status_prepared'),
          horizontalSpace16,
          StatusItemWidget(status: ClassStatus.notPrepared, titleKey: 'status_not_prepared'),
          horizontalSpace16,
          StatusItemWidget(status: ClassStatus.activity, titleKey: 'status_activity'),
        ],
      ),
    );
  }
}

class StatusIcon extends StatelessWidget {
  final ClassStatus status;
  final double size;

  const StatusIcon({super.key, required this.status, this.size = 24});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case ClassStatus.waiting:
        color = ColorsManager.statusWaiting;
        icon = Icons.hourglass_top_rounded;
        break;
      case ClassStatus.prepared:
        color = ColorsManager.statusSuccess;
        icon = Icons.check;
        break;
      case ClassStatus.notPrepared:
        color = ColorsManager.statusWarning;
        icon = Icons.priority_high;
        break;
      case ClassStatus.activity:
        color = ColorsManager.statusActivity;
        icon = Icons.directions_walk;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: size * 0.6,
        ),
      ),
    );
  }
}

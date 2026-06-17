import 'package:flutter/material.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/schedule/data/models/schedule_models.dart';
import 'package:moean/features/schedule/presentation/widgets/status_strip.dart';

class StatusItemWidget extends StatelessWidget {
  final ClassStatus status;
  final String titleKey;

  const StatusItemWidget({
    super.key,
    required this.status,
    required this.titleKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatusIcon(status: status, size: 24),
        horizontalSpace8,
        Text(
          appTranslation().get(titleKey),
          style: TextStylesManager.regular10,
        ),
      ],
    );
  }
}

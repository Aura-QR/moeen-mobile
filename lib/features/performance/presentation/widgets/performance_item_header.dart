import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/document_element_label.dart';
import 'package:moean/features/performance/presentation/widgets/performance_state_chip.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';

/// The element's number, weight, title and evidence state.
class PerformanceItemHeader extends StatelessWidget {
  final PerformanceItemModel item;

  const PerformanceItemHeader({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          [
            if (item.number != null) elementNumberLabel(item.number!),
            if (item.weight != null) appTranslation().get('performance_weight').replaceAll('{n}', '${item.weight}'),
          ].join(' · '),
          style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
        ),
        verticalSpace4,
        Text(item.title, style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText)),
        verticalSpace8,
        PerformanceStateChip(state: item.state, count: item.evidenceCount),
        if (item.evidenceCount == 0) ...[
          verticalSpace8,
          Text(
            appTranslation().get('performance_no_evidence'),
            style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
          ),
        ],
      ],
    );
  }
}

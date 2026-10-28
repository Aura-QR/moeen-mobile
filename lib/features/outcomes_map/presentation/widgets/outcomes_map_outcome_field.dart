import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_models.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_map_synced_field.dart';

/// A single numbered outcome row (field + delete) inside the lesson sheet.
class OutcomesMapOutcomeField extends StatelessWidget {
  final int number;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

  const OutcomesMapOutcomeField({
    super.key,
    required this.number,
    required this.value,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              '$number.',
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
            ),
          ),
          horizontalSpace8,
          Expanded(
            child: OutcomesMapSyncedField(
              value: value,
              hint: appTranslation().get('outcomes_map_outcome_hint'),
              maxLength: OutcomesMapLimits.maxOutcomeLength,
              maxLines: 2,
              onChanged: onChanged,
            ),
          ),
          IconButton(
            tooltip: appTranslation().get('outcomes_map_delete_outcome'),
            onPressed: onDelete,
            icon: Icon(Icons.close_rounded, size: 20, color: ColorsManager.errorColor),
          ),
        ],
      ),
    );
  }
}

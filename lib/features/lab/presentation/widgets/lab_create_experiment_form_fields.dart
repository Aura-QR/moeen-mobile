import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_create_experiment_input.dart';
import 'package:moean/features/lab/presentation/widgets/lab_reading_card_widget.dart';
import 'package:moean/features/lab/presentation/widgets/lab_variable_card_widget.dart';

/// Form fields for [LabCreateExperimentSheet].
class LabCreateExperimentFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController observeController;
  final List<LabVariableFormControllers> variables;
  final List<LabReadingFormControllers> readings;
  final String displayMode;
  final ValueChanged<String> onDisplayModeChanged;
  final VoidCallback onAddVariable;
  final ValueChanged<int> onRemoveVariable;
  final VoidCallback onAddReading;
  final ValueChanged<int> onRemoveReading;

  const LabCreateExperimentFormFields({
    super.key,
    required this.nameController,
    required this.observeController,
    required this.variables,
    required this.readings,
    required this.displayMode,
    required this.onDisplayModeChanged,
    required this.onAddVariable,
    required this.onRemoveVariable,
    required this.onAddReading,
    required this.onRemoveReading,
  });

  @override
  Widget build(BuildContext context) {
    final t = appTranslation();
    final secStyle = TextStylesManager.bold16.copyWith(color: ColorsManager.mainText);
    final activeSymbols = [
      for (var i = 0; i < variables.length; i++) kLabVariableSymbols[i],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryTextField(
          controller: nameController,
          label: t.get('lab_create_name_hint'),
          hint: t.get('lab_create_name_hint'),
        ),
        verticalSpace10,
        Row(
          children: [
            Text(
              t.get('lab_create_display_label'),
              style: TextStylesManager.medium13.copyWith(color: ColorsManager.secondaryText),
            ),
            horizontalSpace12,
            ChoiceChip(
              label: Text(t.get('lab_display_bars')),
              selected: displayMode == 'bars',
              onSelected: (_) => onDisplayModeChanged('bars'),
            ),
            horizontalSpace8,
            ChoiceChip(
              label: Text(t.get('lab_display_graph')),
              selected: displayMode == 'graph',
              onSelected: (_) => onDisplayModeChanged('graph'),
            ),
          ],
        ),
        verticalSpace10,
        PrimaryTextField(
          controller: observeController,
          label: t.get('lab_create_observe_hint'),
          hint: t.get('lab_create_observe_hint'),
          maxLines: 2,
        ),
        verticalSpace16,
        Text(t.get('lab_create_variable_section'), style: secStyle),
        verticalSpace8,
        for (var i = 0; i < variables.length; i++)
          LabVariableCardWidget(
            symbol: kLabVariableSymbols[i],
            controllers: variables[i],
            onRemove: variables.length > 1 ? () => onRemoveVariable(i) : null,
          ),
        if (variables.length < 5)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton(
              onPressed: onAddVariable,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                t.get('lab_create_add_variable').replaceAll('{count}', '${variables.length}'),
                style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
              ),
            ),
          ),
        verticalSpace16,
        Text(t.get('lab_create_reading_section'), style: secStyle),
        verticalSpace8,
        for (var i = 0; i < readings.length; i++)
          LabReadingCardWidget(
            controllers: readings[i],
            availableSymbols: activeSymbols,
            onRemove: readings.length > 1 ? () => onRemoveReading(i) : null,
          ),
        if (readings.length < 4)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton(
              onPressed: onAddReading,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                t.get('lab_create_add_reading').replaceAll('{count}', '${readings.length}'),
                style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
              ),
            ),
          ),
      ],
    );
  }
}

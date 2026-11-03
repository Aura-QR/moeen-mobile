import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_create_experiment_input.dart';

/// Controllers for a single interactive variable row in [LabCreateExperimentSheet].
class LabVariableFormControllers {
  final labelCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final minCtrl = TextEditingController(text: '0');
  final maxCtrl = TextEditingController(text: '100');
  final defaultCtrl = TextEditingController(text: '50');

  LabVariableInput toInput(String symbol) {
    final minVal = parseLabNumber(minCtrl.text, fallback: 0);
    final maxVal = parseLabNumber(maxCtrl.text, fallback: 100);
    final defVal = parseLabNumber(defaultCtrl.text, fallback: (minVal + maxVal) / 2);
    return LabVariableInput(
      symbol: symbol,
      label: labelCtrl.text.trim(),
      unit: unitCtrl.text.trim(),
      min: minVal,
      max: maxVal,
      defaultValue: defVal,
    );
  }

  void dispose() {
    for (final c in [labelCtrl, unitCtrl, minCtrl, maxCtrl, defaultCtrl]) {
      c.dispose();
    }
  }
}

/// Card widget for one variable in «1. ما الذي يحركه الطالب؟».
class LabVariableCardWidget extends StatelessWidget {
  final String symbol;
  final LabVariableFormControllers controllers;
  final VoidCallback? onRemove;

  const LabVariableCardWidget({
    super.key,
    required this.symbol,
    required this.controllers,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = appTranslation();
    final symbolText = t.get('lab_create_symbol_label').replaceAll('{symbol}', symbol);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.primaryColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: PrimaryTextField(
                  controller: controllers.labelCtrl,
                  label: t.get('lab_create_var_label_hint'),
                  hint: t.get('lab_create_var_label_hint'),
                ),
              ),
              horizontalSpace8,
              Expanded(
                child: PrimaryTextField(
                  controller: controllers.unitCtrl,
                  label: t.get('lab_create_unit_hint'),
                  hint: t.get('lab_create_unit_hint'),
                ),
              ),
            ],
          ),
          verticalSpace8,
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: controllers.minCtrl,
                  label: t.get('lab_create_min_hint'),
                  hint: '0',
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                ),
              ),
              horizontalSpace8,
              Expanded(
                child: PrimaryTextField(
                  controller: controllers.maxCtrl,
                  label: t.get('lab_create_max_hint'),
                  hint: '100',
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
          ),
          verticalSpace8,
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: controllers.defaultCtrl,
                  label: t.get('lab_create_default_hint'),
                  hint: '50',
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                ),
              ),
              horizontalSpace12,
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(symbolText, style: TextStylesManager.bold13.copyWith(color: ColorsManager.secondaryText)),
                    if (onRemove != null)
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline_rounded, color: ColorsManager.errorColor, size: 20),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_create_experiment_input.dart';

/// Controllers for a single reading row in [LabCreateExperimentSheet].
class LabReadingFormControllers {
  final labelCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final formulaCtrl = TextEditingController(text: 'a');

  void insertToken(String token) {
    final text = formulaCtrl.text;
    final sel = formulaCtrl.selection;
    if (sel.isValid && sel.start >= 0 && sel.end <= text.length) {
      final updated = text.replaceRange(sel.start, sel.end, token);
      formulaCtrl.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: sel.start + token.length),
      );
    } else {
      final updated = '$text$token';
      formulaCtrl.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: updated.length),
      );
    }
  }

  LabReadingInput toInput() => LabReadingInput(
        label: labelCtrl.text.trim(),
        unit: unitCtrl.text.trim(),
        formula: formulaCtrl.text.trim(),
      );

  void dispose() {
    for (final c in [labelCtrl, unitCtrl, formulaCtrl]) {
      c.dispose();
    }
  }
}

/// Card widget for one reading in «2. ماذا يُحسب منه؟».
class LabReadingCardWidget extends StatelessWidget {
  final LabReadingFormControllers controllers;
  final List<String> availableSymbols;
  final VoidCallback? onRemove;

  const LabReadingCardWidget({
    super.key,
    required this.controllers,
    required this.availableSymbols,
    this.onRemove,
  });

  static const List<MapEntry<String, String>> _operatorTokens = [
    MapEntry('+', ' + '),
    MapEntry('-', ' - '),
    MapEntry('×', ' * '),
    MapEntry('÷', ' / '),
    MapEntry('(', '('),
    MapEntry(')', ')'),
    MapEntry('^', '^'),
    MapEntry('√', 'sqrt('),
  ];

  @override
  Widget build(BuildContext context) {
    final t = appTranslation();
    final tokens = <MapEntry<String, String>>[
      for (final sym in availableSymbols) MapEntry(sym, sym),
      ..._operatorTokens,
    ];

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
                  label: t.get('lab_create_read_label_hint'),
                  hint: t.get('lab_create_read_label_hint'),
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
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon:  Icon(Icons.delete_outline_rounded, color: ColorsManager.errorColor, size: 20),
                ),
            ],
          ),
          verticalSpace8,
          PrimaryTextField(
            controller: controllers.formulaCtrl,
            label: t.get('lab_create_formula_hint'),
            hint: 'a',
            textDirection: TextDirection.ltr,
          ),
          verticalSpace8,
          Directionality(
            textDirection: TextDirection.ltr,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final entry in tokens)
                  InkWell(
                    onTap: () => controllers.insertToken(entry.value),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.key,
                        style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

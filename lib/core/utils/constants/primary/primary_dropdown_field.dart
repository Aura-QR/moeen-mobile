import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

/// A reusable labeled dropdown field with a rounded, filled decoration.
///
/// Keeps a single consistent look for every "pick one" field across the app
/// (stage, grade, subject, …) instead of mixing chips, sheets and dropdowns.
class PrimaryDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const PrimaryDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStylesManager.regular14.copyWith(color: ColorsManager.mainText);
    final hintStyle = TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText);
    final hasValue = value != null && items.contains(value);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
        filled: true,
        fillColor: ColorsManager.surfacePrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorsManager.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: hasValue ? ColorsManager.primaryColor : ColorsManager.borderColor,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: ColorsManager.borderLightGray),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: hasValue ? value : null,
          isExpanded: true,
          dropdownColor: ColorsManager.surfacePrimary,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: ColorsManager.mainText),
          hint: Text(hint, style: hintStyle, overflow: TextOverflow.ellipsis),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item,
                child: Text(labelOf(item), style: textStyle, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}

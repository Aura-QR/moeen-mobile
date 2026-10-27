import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

/// Reusable dropdown form field for curriculum cascading selectors.
class ConceptMapDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool isLoading;
  final IconData? icon;

  const ConceptMapDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && items.any((item) => item.value == value);

    return DropdownButtonFormField<T>(
      key: ValueKey<String>('$label-$value'),
      initialValue: hasValue ? value : null,
      isExpanded: true,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(16),
      dropdownColor: ColorsManager.surfacePrimary,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.keyboard_arrow_down_rounded,
              color: onChanged == null
                  ? ColorsManager.borderColor
                  : ColorsManager.secondaryText,
            ),
      style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStylesManager.regular14.copyWith(
          color: ColorsManager.secondaryText,
        ),
        hintText: hint,
        hintStyle: TextStylesManager.regular14.copyWith(
          color: ColorsManager.secondaryText,
        ),
        filled: true,
        fillColor: onChanged == null
            ? ColorsManager.background.withValues(alpha: 0.5)
            : ColorsManager.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        prefixIcon: icon != null
            ? Icon(
                icon,
                size: 20,
                color: onChanged == null
                    ? ColorsManager.borderColor
                    : ColorsManager.primaryColor,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ColorsManager.borderLightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ColorsManager.borderLightGray),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorsManager.borderLightGray.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ColorsManager.primaryColor, width: 1.5),
        ),
      ),
      items: items,
    );
  }
}

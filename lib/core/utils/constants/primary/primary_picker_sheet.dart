import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';

/// One row of a [PrimaryPickerSheet].
class PrimaryPickerOption<T> {
  final T value;
  final String label;

  /// A smaller line under the label.
  final String? subtitle;

  const PrimaryPickerOption({required this.value, required this.label, this.subtitle});
}

/// A bottom sheet that lists options and pops with the tapped one. Pops
/// nothing when dismissed, so a caller can tell a pick from a dismissal.
class PrimaryPickerSheet<T> extends StatelessWidget {
  final String title;
  final List<PrimaryPickerOption<T>> options;
  final T? selected;

  const PrimaryPickerSheet({super.key, required this.title, required this.options, this.selected});

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<PrimaryPickerOption<T>> options,
    T? selected,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.surfacePrimary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => PrimaryPickerSheet<T>(title: title, options: options, selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(title, style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option.value == selected;
                  return ListTile(
                    onTap: () => Navigator.pop(context, option.value),
                    title: Text(
                      option.label,
                      style: TextStylesManager.medium14.copyWith(
                        color: isSelected ? ColorsManager.primaryColor : ColorsManager.mainText,
                      ),
                    ),
                    subtitle: option.subtitle == null
                        ? null
                        : Text(
                            option.subtitle!,
                            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                          ),
                    trailing: isSelected ? Icon(Icons.check_rounded, color: ColorsManager.primaryColor) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

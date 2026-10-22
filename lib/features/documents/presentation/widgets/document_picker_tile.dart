import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// A tappable field that opens a picker (strategy, date…). Shows [hint]
/// until [value] is set.
class DocumentPickerTile extends StatelessWidget {
  final IconData icon;
  final String hint;
  final String? value;
  final VoidCallback onTap;
  final bool isLoading;

  const DocumentPickerTile({
    super.key,
    required this.icon,
    required this.hint,
    required this.onTap,
    this.value,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Material(
      color: ColorsManager.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasValue ? ColorsManager.primaryColor.withValues(alpha: 0.5) : ColorsManager.borderColor,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: hasValue ? ColorsManager.primaryColor : ColorsManager.secondaryText),
              horizontalSpace12,
              Expanded(
                child: Text(
                  hasValue ? value! : hint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: hasValue
                      ? TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)
                      : TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: ColorsManager.primaryColor),
                )
              else
                Icon(Icons.keyboard_arrow_down_rounded, color: ColorsManager.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

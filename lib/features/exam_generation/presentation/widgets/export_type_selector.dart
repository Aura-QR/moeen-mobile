import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

/// A segmented control that lets the teacher pick whether the export is a
/// graded «اختبار» or a practice «ورقة عمل». Defaults to «اختبار».
class ExportTypeSelector extends StatelessWidget {
  final bool isWorksheet;
  final ValueChanged<bool> onChanged;

  const ExportTypeSelector({
    super.key,
    required this.isWorksheet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ExportTypeSegment(
              label: appTranslation().get('export_type_exam'),
              selected: !isWorksheet,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ExportTypeSegment(
              label: appTranslation().get('export_type_worksheet'),
              selected: isWorksheet,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportTypeSegment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ExportTypeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? ColorsManager.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStylesManager.bold14.copyWith(
            color: selected ? Colors.white : ColorsManager.secondaryText,
          ),
        ),
      ),
    );
  }
}

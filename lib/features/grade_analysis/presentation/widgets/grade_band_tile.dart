import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/grade_analysis/data/models/grade_options_model.dart';
import 'package:moean/features/grade_analysis/data/utils/grade_numbers.dart';

/// One level: its name and where it starts, with «تعديل» and «حذف».
class GradeBandTile extends StatelessWidget {
  final GradeBand band;
  final VoidCallback onEdit;

  /// Null when the level can't be removed (the minimum is reached).
  final VoidCallback? onRemove;

  const GradeBandTile({super.key, required this.band, required this.onEdit, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(band.label, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
      subtitle: Text(
        appTranslation().get('grades_band_from').replaceAll('{min}', formatGrade(band.min)),
        style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: appTranslation().get('edit'),
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.edit_outlined, size: 18, color: ColorsManager.secondaryText),
          ),
          IconButton(
            tooltip: appTranslation().get('delete'),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 18, color: ColorsManager.secondaryText),
          ),
        ],
      ),
    );
  }
}

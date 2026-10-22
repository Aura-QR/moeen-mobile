import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/classes/presentation/cubit/madrasati_import_cubit.dart';

/// A Madrasati class to tick, with how far its import got.
class MadrasatiClassTile extends StatelessWidget {
  final MadrasatiImportRow row;

  /// Null while the classes can't be changed.
  final VoidCallback? onToggle;

  const MadrasatiClassTile({super.key, required this.row, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final status = switch (row.status) {
      MadrasatiRowStatus.reading => appTranslation().get('classes_madrasati_reading'),
      MadrasatiRowStatus.read || MadrasatiRowStatus.saved =>
        appTranslation().get('classes_madrasati_count').replaceAll('{count}', '${row.students.length}'),
      MadrasatiRowStatus.failed => appTranslation().get('classes_madrasati_failed'),
      MadrasatiRowStatus.idle => '',
    };
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: row.isChecked,
      onChanged: onToggle == null ? null : (_) => onToggle!(),
      activeColor: ColorsManager.primaryColor,
      title: Text(row.madrasatiClass.name, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
      subtitle: Text(
        [
          status,
          if (row.status == MadrasatiRowStatus.read && row.replacesExisting)
            appTranslation().get('classes_madrasati_replaces'),
        ].where((text) => text.isNotEmpty).join(' · '),
        style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
      ),
    );
  }
}

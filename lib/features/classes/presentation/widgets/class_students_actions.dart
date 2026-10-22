import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// «إضافة أسماء» and «استيراد من Excel».
class ClassStudentsActions extends StatelessWidget {
  final bool isImporting;
  final bool enabled;
  final VoidCallback onPaste;
  final VoidCallback onImport;

  const ClassStudentsActions({
    super.key,
    required this.isImporting,
    required this.enabled,
    required this.onPaste,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: ColorsManager.primaryColor,
      side: BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 12),
      textStyle: TextStylesManager.bold13,
    );
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: style,
            onPressed: enabled ? onPaste : null,
            icon: const Icon(Icons.format_list_bulleted_add, size: 20),
            label: Text(appTranslation().get('class_paste_names')),
          ),
        ),
        horizontalSpace10,
        Expanded(
          child: OutlinedButton.icon(
            style: style,
            onPressed: enabled && !isImporting ? onImport : null,
            icon: isImporting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: ColorsManager.primaryColor),
                  )
                : const Icon(Icons.table_view_outlined, size: 20),
            label: Text(appTranslation().get('class_import_excel')),
          ),
        ),
      ],
    );
  }
}

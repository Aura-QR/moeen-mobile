import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// A document tool's bottom bar: «حفظ»، «تصدير»، «إضافة إلى ملف الإنجاز».
class DocumentActionsBar extends StatelessWidget {
  final bool enabled;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onExport;
  final VoidCallback onAttach;

  const DocumentActionsBar({
    super.key,
    required this.enabled,
    required this.isSaving,
    required this.onSave,
    required this.onExport,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        border: Border(top: BorderSide(color: ColorsManager.borderLightGray)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: PrimaryElevatedButton(
                    text: appTranslation().get('save'),
                    icon: const Icon(Icons.save_outlined, size: 20),
                    isLoading: isSaving,
                    backgroundColor: ColorsManager.themeDarkPrimary,
                    onPressed: enabled ? onSave : null,
                  ),
                ),
                horizontalSpace10,
                Expanded(
                  child: PrimaryElevatedButton(
                    text: appTranslation().get('document_export'),
                    icon: const Icon(Icons.ios_share_rounded, size: 20),
                    onPressed: enabled ? onExport : null,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: enabled ? onAttach : null,
              icon: const Icon(Icons.workspace_premium_outlined, size: 20),
              label: Text(appTranslation().get('document_add_to_portfolio'), style: TextStylesManager.bold13),
            ),
          ],
        ),
      ),
    );
  }
}

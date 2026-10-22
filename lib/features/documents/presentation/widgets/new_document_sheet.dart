import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/document_tools.dart';

/// «مستند جديد»: pick a tool. Pops with it.
class NewDocumentSheet extends StatelessWidget {
  const NewDocumentSheet({super.key});

  static Future<DocumentTool?> show(BuildContext context) {
    return showModalBottomSheet<DocumentTool>(
      context: context,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const NewDocumentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appTranslation().get('document_new'),
              style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace12,
            for (final tool in documentTools)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  child: Icon(tool.icon, color: ColorsManager.primaryColor),
                ),
                title: Text(
                  appTranslation().get(tool.titleKey),
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                ),
                subtitle: Text(
                  appTranslation().get(tool.subtitleKey),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
                onTap: () => Navigator.pop(context, tool),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_file_source_sheet.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// One header logo slot. Saved logos have no URL, so they show as «مرفوع».
class DocumentLogoPicker extends StatelessWidget {
  final String labelKey;
  final bool hasLogo;
  final Uint8List? preview;
  final bool isUploading;
  final ValueChanged<DeviceFileSource> onPick;
  final VoidCallback onRemove;

  const DocumentLogoPicker({
    super.key,
    required this.labelKey,
    required this.hasLogo,
    required this.preview,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  Future<void> _pick(BuildContext context) async {
    final source = await PrimaryFileSourceSheet.show(
      context,
      titleKey: labelKey,
      sources: const [DeviceFileSource.camera, DeviceFileSource.gallery],
    );
    if (source != null) onPick(source);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = preview;
    return Column(
      children: [
        Material(
          color: ColorsManager.background,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: isUploading ? null : () => _pick(context),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 104,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: hasLogo ? ColorsManager.primaryColor : ColorsManager.borderColor),
              ),
              child: isUploading
                  ? Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: ColorsManager.primaryColor))
                  : bytes != null
                      ? Image.memory(bytes, fit: BoxFit.contain)
                      : Icon(
                          hasLogo ? Icons.verified_rounded : Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: hasLogo ? ColorsManager.primaryColor : ColorsManager.secondaryText,
                        ),
            ),
          ),
        ),
        verticalSpace6,
        Text(
          appTranslation().get(hasLogo && bytes == null ? 'document_logo_uploaded' : labelKey),
          style: TextStylesManager.medium12.copyWith(color: ColorsManager.mainText),
        ),
        if (hasLogo)
          TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(foregroundColor: ColorsManager.errorColor, visualDensity: VisualDensity.compact),
            child: Text(appTranslation().get('document_logo_remove')),
          ),
      ],
    );
  }
}

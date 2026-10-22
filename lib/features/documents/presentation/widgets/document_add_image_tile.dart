import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// The «إضافة صورة» tile; shows a spinner while a photo uploads.
class DocumentAddImageTile extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onTap;

  const DocumentAddImageTile({super.key, required this.isUploading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColorsManager.primaryColor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isUploading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: isUploading
              ? CircularProgressIndicator(strokeWidth: 2.5, color: ColorsManager.primaryColor)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: ColorsManager.primaryColor, size: 28),
                    verticalSpace6,
                    Text(
                      appTranslation().get('document_add_photo'),
                      style: TextStylesManager.medium12.copyWith(color: ColorsManager.primaryColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

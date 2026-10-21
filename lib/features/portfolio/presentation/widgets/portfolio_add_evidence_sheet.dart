import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/data/models/portfolio_upload_models.dart';

/// «الكاميرا»، «الصور»، «ملف PDF». Pops with the chosen source.
class PortfolioAddEvidenceSheet extends StatelessWidget {
  const PortfolioAddEvidenceSheet({super.key});

  static Future<PortfolioFileSource?> show(BuildContext context) {
    return showModalBottomSheet<PortfolioFileSource>(
      context: context,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const PortfolioAddEvidenceSheet(),
    );
  }

  static const _options = [
    (PortfolioFileSource.camera, Icons.photo_camera_outlined, 'portfolio_source_camera'),
    (PortfolioFileSource.gallery, Icons.photo_library_outlined, 'portfolio_source_gallery'),
    (PortfolioFileSource.pdf, Icons.picture_as_pdf_outlined, 'portfolio_source_pdf'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appTranslation().get('portfolio_add_evidence'),
              style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace16,
            Row(
              children: [
                for (final (source, icon, labelKey) in _options)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => Navigator.pop(context, source),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: ColorsManager.primaryColor.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              Icon(icon, color: ColorsManager.primaryColor, size: 28),
                              verticalSpace8,
                              Text(
                                appTranslation().get(labelKey),
                                style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/document_preview_image.dart';

/// «المعاينة»: the first certificate, re-rendered a moment after each change.
class CertificatesPreviewCard extends StatelessWidget {
  const CertificatesPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.preview_outlined,
      title: appTranslation().get('certificates_section_preview'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DocumentPreviewImage(),
          verticalSpace8,
          Text(
            appTranslation().get('certificates_preview_note'),
            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
          ),
        ],
      ),
    );
  }
}

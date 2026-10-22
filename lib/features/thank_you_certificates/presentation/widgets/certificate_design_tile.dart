import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/thank_you_certificates/data/models/certificates_catalogue_model.dart';

/// One design: its empty background and name, outlined when chosen.
class CertificateDesignTile extends StatelessWidget {
  final CertificateDesignModel design;
  final bool isSelected;
  final VoidCallback onTap;

  const CertificateDesignTile({super.key, required this.design, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? ColorsManager.primaryColor : ColorsManager.borderLightGray;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ColoredBox(
                  color: ColorsManager.white,
                  child: Image.network(
                    design.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.image_not_supported_outlined, color: ColorsManager.secondaryText),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected) Icon(Icons.check_circle_rounded, size: 14, color: ColorsManager.primaryColor),
                  Flexible(
                    child: Text(
                      ' ${design.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStylesManager.medium12.copyWith(
                        color: isSelected ? ColorsManager.primaryColor : ColorsManager.mainText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

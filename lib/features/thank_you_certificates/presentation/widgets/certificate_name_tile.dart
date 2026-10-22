import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

/// One name of the list, with «معاينة» and «حذف».
class CertificateNameTile extends StatelessWidget {
  final int number;
  final String name;
  final VoidCallback onPreview;
  final VoidCallback onRemove;

  const CertificateNameTile({
    super.key,
    required this.number,
    required this.name,
    required this.onPreview,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$number', style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor)),
          ),
          Expanded(
            child: Text(name, style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText)),
          ),
          IconButton(
            tooltip: appTranslation().get('certificates_preview'),
            onPressed: onPreview,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.visibility_outlined, size: 20, color: ColorsManager.primaryColor),
          ),
          IconButton(
            tooltip: appTranslation().get('delete'),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 20, color: ColorsManager.secondaryText),
          ),
        ],
      ),
    );
  }
}

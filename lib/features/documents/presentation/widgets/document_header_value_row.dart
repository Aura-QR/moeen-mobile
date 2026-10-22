import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// A read-only header value: «المدرسة: …».
class DocumentHeaderValueRow extends StatelessWidget {
  final String label;
  final String value;

  const DocumentHeaderValueRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText)),
          ),
          horizontalSpace8,
          Expanded(
            child: Text(
              isEmpty ? appTranslation().get('document_value_missing') : value,
              style: isEmpty
                  ? TextStylesManager.regular13.copyWith(color: ColorsManager.statusWarning)
                  : TextStylesManager.medium13.copyWith(color: ColorsManager.mainText),
            ),
          ),
        ],
      ),
    );
  }
}

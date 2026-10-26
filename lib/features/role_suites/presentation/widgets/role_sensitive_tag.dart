import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';

/// Grey «نموذج للطباعة والتعبئة باليد» tag shown on sensitive forms.
class RoleSensitiveTag extends StatelessWidget {
  const RoleSensitiveTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ColorsManager.secondaryText.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        appTranslation().get('role_docs_sensitive_tag'),
        style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
      ),
    );
  }
}

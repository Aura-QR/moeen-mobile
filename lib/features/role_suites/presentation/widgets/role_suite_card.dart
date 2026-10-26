import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/presentation/role_suite_style.dart';

/// Card for one school role in «حقائب الأدوار», highlighting the teacher's active portfolio role.
class RoleSuiteCard extends StatelessWidget {
  final RoleSuiteSummary role;
  final bool isMatched;
  final VoidCallback onTap;

  const RoleSuiteCard({
    super.key,
    required this.role,
    required this.isMatched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isMatched
        ? ColorsManager.primaryColor.withValues(alpha: 0.5)
        : ColorsManager.borderLightGray;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isMatched
                ? ColorsManager.primaryColor.withValues(alpha: 0.05)
                : ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: isMatched ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  roleSuiteIcon(role.key),
                  color: ColorsManager.primaryColor,
                  size: 26,
                ),
              ),
              horizontalSpace14,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMatched) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          appTranslation().get('role_suites_your_role'),
                          style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                        ),
                      ),
                      verticalSpace6,
                    ],
                    Text(
                      role.label,
                      style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                    ),
                    if (role.description.isNotEmpty) ...[
                      verticalSpace4,
                      Text(
                        role.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                      ),
                    ],
                    verticalSpace6,
                    Text(
                      appTranslation()
                          .get('role_suites_count')
                          .replaceAll('{count}', '${role.documentsCount}'),
                      style: TextStylesManager.medium12.copyWith(color: ColorsManager.primaryColor),
                    ),
                  ],
                ),
              ),
              horizontalSpace8,
              Icon(Icons.chevron_left_rounded, color: ColorsManager.secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}

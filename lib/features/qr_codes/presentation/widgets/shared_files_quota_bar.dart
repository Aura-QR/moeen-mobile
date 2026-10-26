import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/data/models/shared_files_meta_model.dart';
import 'package:moean/features/qr_codes/data/utils/format_bytes.dart';

class SharedFilesQuotaBar extends StatelessWidget {
  final SharedFilesMetaModel meta;

  const SharedFilesQuotaBar({
    super.key,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final usedStr = formatBytes(meta.usedBytes);
    final quotaStr = formatBytes(meta.quotaBytes);
    final label = appTranslation()
        .get('qr_used_space')
        .replaceAll('{used}', usedStr)
        .replaceAll('{quota}', quotaStr);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStylesManager.bold13.copyWith(
                    color: ColorsManager.mainText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              horizontalSpace8,
              Text(
                '${(meta.usedRatio * 100).toInt()}%',
                style: TextStylesManager.bold13.copyWith(
                  color: ColorsManager.primaryColor,
                ),
              ),
            ],
          ),
          verticalSpace10,
          LinearProgressIndicator(
            value: meta.usedRatio,
            backgroundColor: ColorsManager.borderLightGray.withValues(alpha: 0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              meta.usedRatio > 0.9
                  ? ColorsManager.errorColor
                  : ColorsManager.primaryColor,
            ),
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}

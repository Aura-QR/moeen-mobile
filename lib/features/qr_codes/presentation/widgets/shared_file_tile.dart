import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/data/models/shared_file_model.dart';
import 'package:moean/features/qr_codes/data/utils/format_bytes.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_files_list_cubit.dart';
import 'package:moean/features/qr_codes/presentation/widgets/shared_file_extend_sheet.dart';

class SharedFileTile extends StatelessWidget {
  final SharedFileModel file;
  final List<int> expiryOptions;

  const SharedFileTile({
    super.key,
    required this.file,
    required this.expiryOptions,
  });

  IconData _iconForKind(SharedFileKind kind) {
    switch (kind) {
      case SharedFileKind.pdf:
        return Icons.picture_as_pdf_outlined;
      case SharedFileKind.image:
        return Icons.image_outlined;
      case SharedFileKind.video:
        return Icons.video_file_outlined;
      case SharedFileKind.word:
        return Icons.description_outlined;
      case SharedFileKind.excel:
        return Icons.table_chart_outlined;
      case SharedFileKind.powerpoint:
        return Icons.slideshow_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadsText = appTranslation()
        .get('qr_downloads')
        .replaceAll('{n}', '${file.downloads}');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: file.isExpired
              ? ColorsManager.errorColor.withValues(alpha: 0.3)
              : ColorsManager.borderLightGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForKind(file.kind),
                  color: ColorsManager.primaryColor,
                  size: 24,
                ),
              ),
              horizontalSpace12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      file.displayName,
                      style: TextStylesManager.bold14.copyWith(
                        color: ColorsManager.mainText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    verticalSpace4,
                    Text(
                      '${formatBytes(file.byteSize)} • $downloadsText',
                      style: TextStylesManager.regular12.copyWith(
                        color: ColorsManager.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              if (file.isExpired)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorsManager.errorColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appTranslation().get('qr_expired'),
                    style: TextStylesManager.bold12.copyWith(
                      color: ColorsManager.errorColor,
                    ),
                  ),
                ),
            ],
          ),
          verticalSpace12,
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final detailed = await SharedFilesListCubit.get(context)
                      .openQr(file.id);
                  if (detailed != null && context.mounted) {
                    Navigator.pushNamed(
                      context,
                      Routes.sharedFileResult,
                      arguments: detailed,
                    ).then((_) {
                      if (context.mounted) {
                        SharedFilesListCubit.get(context).refresh();
                      }
                    });
                  }
                },
                icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                label: Text(appTranslation().get('qr_show_code')),
                style: TextButton.styleFrom(
                  foregroundColor: ColorsManager.primaryColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  SharedFileExtendSheet.show(
                    context,
                    fileId: file.id,
                    expiryDays: expiryOptions,
                  );
                },
                icon: const Icon(Icons.update_rounded, size: 18),
                label: Text(appTranslation().get('qr_extend')),
                style: TextButton.styleFrom(
                  foregroundColor: ColorsManager.primaryColor,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: ColorsManager.errorColor,
                  size: 20,
                ),
                onPressed: () async {
                  final confirmed = await showPrimaryConfirmDialog(
                    context,
                    titleKey: 'delete',
                    messageKey: 'qr_delete_confirm',
                  );
                  if (confirmed && context.mounted) {
                    SharedFilesListCubit.get(context).delete(file.id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

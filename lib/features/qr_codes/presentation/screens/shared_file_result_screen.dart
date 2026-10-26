import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/data/models/shared_file_model.dart';
import 'package:moean/features/qr_codes/data/services/qr_export_service.dart';
import 'package:moean/features/qr_codes/data/utils/format_bytes.dart';
import 'package:moean/features/qr_codes/presentation/widgets/qr_actions_row.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class SharedFileResultScreen extends StatelessWidget {
  final SharedFileModel file;

  const SharedFileResultScreen({
    super.key,
    required this.file,
  });

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final qrBytes = file.qrPngBytes;

    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        title: Text(
          file.displayName,
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColorsManager.borderLightGray),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: qrBytes != null
                      ? Image.memory(
                          qrBytes,
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        )
                      : QrImageView(
                          data: file.shareUrl,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                ),
              ),
              verticalSpace16,
              Text(
                file.displayName,
                style: TextStylesManager.bold16.copyWith(
                  color: ColorsManager.mainText,
                ),
                textAlign: TextAlign.center,
              ),
              verticalSpace4,
              Text(
                '${file.fileName} • ${formatBytes(file.byteSize)}',
                style: TextStylesManager.regular13.copyWith(
                  color: ColorsManager.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              if (file.expiresAt != null) ...[
                verticalSpace6,
                Text(
                  appTranslation().get('qr_expires_on').replaceAll(
                        '{date}',
                        _formatDate(file.expiresAt!),
                      ),
                  style: TextStylesManager.medium12.copyWith(
                    color: ColorsManager.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              verticalSpace16,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorsManager.surfacePrimary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.borderLightGray),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      color: ColorsManager.primaryColor,
                      size: 20,
                    ),
                    horizontalSpace8,
                    Expanded(
                      child: Text(
                        file.shareUrl,
                        style: TextStylesManager.medium12.copyWith(
                          color: ColorsManager.mainText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: file.shareUrl));
                        showPrimarySnackBar(
                          context,
                          'qr_link_copied',
                          isError: false,
                        );
                      },
                      child: Text(
                        appTranslation().get('qr_copy_link'),
                        style: TextStylesManager.bold12.copyWith(
                          color: ColorsManager.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpace12,
              OutlinedButton.icon(
                onPressed: () {
                  final text = '${file.displayName}\n${file.shareUrl}';
                  SharePlus.instance.share(ShareParams(text: text));
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                label: Text(appTranslation().get('qr_share_link')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: ColorsManager.primaryColor,
                  side: BorderSide(color: ColorsManager.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              verticalSpace20,
              QrActionsRow(
                getPngBytes: () async {
                  if (qrBytes != null) return qrBytes;
                  return QrExportService().pngBytes(data: file.shareUrl);
                },
                link: file.shareUrl,
                caption: file.displayName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

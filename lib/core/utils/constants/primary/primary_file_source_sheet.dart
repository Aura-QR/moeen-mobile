import 'package:flutter/material.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_file_source_option.dart';
import 'package:moean/core/utils/constants/spacing.dart';

/// «الكاميرا»، «الصور»، «ملف PDF». Pops with the chosen source.
class PrimaryFileSourceSheet extends StatelessWidget {
  final String titleKey;
  final List<DeviceFileSource> sources;

  const PrimaryFileSourceSheet({super.key, required this.titleKey, required this.sources});

  static Future<DeviceFileSource?> show(
    BuildContext context, {
    required String titleKey,
    List<DeviceFileSource> sources = DeviceFileSource.values,
  }) {
    return showModalBottomSheet<DeviceFileSource>(
      context: context,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => PrimaryFileSourceSheet(titleKey: titleKey, sources: sources),
    );
  }

  static const _icons = {
    DeviceFileSource.camera: Icons.photo_camera_outlined,
    DeviceFileSource.gallery: Icons.photo_library_outlined,
    DeviceFileSource.pdf: Icons.picture_as_pdf_outlined,
  };

  static const _labelKeys = {
    DeviceFileSource.camera: 'file_source_camera',
    DeviceFileSource.gallery: 'file_source_gallery',
    DeviceFileSource.pdf: 'file_source_pdf',
  };

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
              appTranslation().get(titleKey),
              style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace16,
            Row(
              children: [
                for (final source in sources)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: PrimaryFileSourceOption(
                        icon: _icons[source]!,
                        label: appTranslation().get(_labelKeys[source]!),
                        onTap: () => Navigator.pop(context, source),
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

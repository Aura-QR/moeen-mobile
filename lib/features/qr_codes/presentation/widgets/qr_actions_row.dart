import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/presentation/cubit/qr_export_cubit.dart';
import 'package:moean/features/qr_codes/presentation/cubit/qr_export_state.dart';
import 'package:moean/features/qr_codes/presentation/widgets/qr_action_button_item.dart';

class QrActionsRow extends StatelessWidget {
  final Future<Uint8List> Function() getPngBytes;
  final String link;
  final String? caption;
  final bool enabled;

  const QrActionsRow({
    super.key,
    required this.getPngBytes,
    required this.link,
    this.caption,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QrExportCubit, QrExportState>(
      listenWhen: (previous, current) =>
          current.message != null && previous.message != current.message,
      listener: (context, state) {
        if (state.message != null) {
          showPrimarySnackBar(
            context,
            state.message!,
            isError: !state.isSuccess,
          );
          QrExportCubit.get(context).clearMessage();
        }
      },
      buildWhen: (previous, current) =>
          previous.isExporting != current.isExporting,
      builder: (context, state) {
        final isBusy = state.isExporting;

        return Row(
          children: [
            Expanded(
              child: QrActionButtonItem(
                icon: Icons.save_alt_rounded,
                label: appTranslation().get('qr_save_gallery'),
                enabled: enabled && !isBusy,
                onTap: () async {
                  final bytes = await getPngBytes();
                  if (context.mounted) {
                    QrExportCubit.get(context).saveToGallery(
                      png: bytes,
                      name: 'qr_${DateTime.now().millisecondsSinceEpoch}.png',
                    );
                  }
                },
              ),
            ),
            horizontalSpace8,
            Expanded(
              child: QrActionButtonItem(
                icon: Icons.share_rounded,
                label: appTranslation().get('qr_share_image'),
                enabled: enabled && !isBusy,
                onTap: () async {
                  final bytes = await getPngBytes();
                  if (context.mounted) {
                    QrExportCubit.get(context).shareImage(
                      png: bytes,
                      link: link,
                    );
                  }
                },
              ),
            ),
            horizontalSpace8,
            Expanded(
              child: QrActionButtonItem(
                icon: Icons.picture_as_pdf_outlined,
                label: appTranslation().get('qr_share_pdf'),
                enabled: enabled && !isBusy,
                onTap: () async {
                  final bytes = await getPngBytes();
                  if (context.mounted) {
                    QrExportCubit.get(context).sharePdf(
                      qrPng: bytes,
                      caption: caption,
                      link: link,
                    );
                  }
                },
              ),
            ),
            horizontalSpace8,
            Expanded(
              child: QrActionButtonItem(
                icon: Icons.print_outlined,
                label: appTranslation().get('qr_print'),
                enabled: enabled && !isBusy,
                onTap: () async {
                  final bytes = await getPngBytes();
                  if (context.mounted) {
                    QrExportCubit.get(context).printPdf(
                      qrPng: bytes,
                      caption: caption,
                      link: link,
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/presentation/cubit/link_qr_cubit.dart';
import 'package:moean/features/qr_codes/presentation/cubit/link_qr_state.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPreviewCard extends StatelessWidget {
  const QrPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LinkQrCubit, LinkQrState>(
      buildWhen: (previous, current) =>
          previous.url != current.url ||
          previous.caption != current.caption ||
          previous.isValid != current.isValid ||
          previous.logoBytes != current.logoBytes,
      builder: (context, state) {
        if (!state.isValid || state.url.isEmpty) {
          return Container(
            height: 240,
            decoration: BoxDecoration(
              color: ColorsManager.surfacePrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorsManager.borderLightGray),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 64,
                    color: ColorsManager.secondaryText.withValues(alpha: 0.4),
                  ),
                  verticalSpace12,
                  Text(
                    appTranslation().get('qr_preview_empty'),
                    style: TextStylesManager.medium13.copyWith(
                      color: ColorsManager.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsManager.borderLightGray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorsManager.borderLightGray),
                ),
                child: QrImageView(
                  data: state.url,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: state.logoBytes == null
                      ? QrErrorCorrectLevel.M
                      : QrErrorCorrectLevel.H,
                  embeddedImage: state.logoBytes != null
                      ? MemoryImage(state.logoBytes!)
                      : null,
                  embeddedImageStyle: const QrEmbeddedImageStyle(
                    size: Size(44, 44),
                  ),
                ),
              ),
              if (state.caption.trim().isNotEmpty) ...[
                verticalSpace12,
                Text(
                  state.caption.trim(),
                  style: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.mainText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

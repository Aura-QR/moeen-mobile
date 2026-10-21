import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// The live share link with copy, QR and the system share sheet.
class PortfolioShareLinkWidget extends StatelessWidget {
  final String url;

  const PortfolioShareLinkWidget({super.key, required this.url});

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) showPrimarySnackBar(context, 'copy_success', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorsManager.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColorsManager.borderLightGray),
            ),
            child: QrImageView(data: url, size: 170, padding: EdgeInsets.zero),
          ),
        ),
        verticalSpace16,
        Container(
          padding: const EdgeInsetsDirectional.only(start: 14),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColorsManager.borderLightGray),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                  style: TextStylesManager.regular13.copyWith(color: ColorsManager.mainText),
                ),
              ),
              IconButton(
                onPressed: () => _copy(context),
                icon: Icon(Icons.copy_rounded, color: ColorsManager.primaryColor),
              ),
            ],
          ),
        ),
        verticalSpace12,
        PrimaryElevatedButton(
          text: appTranslation().get('portfolio_share_link'),
          icon: const Icon(Icons.ios_share_rounded, size: 20),
          onPressed: () => SharePlus.instance.share(ShareParams(text: url)),
        ),
      ],
    );
  }
}

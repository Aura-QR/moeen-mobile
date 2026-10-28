import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/learning_styles/data/models/learning_styles_models.dart';
import 'package:moean/features/learning_styles/presentation/widgets/learning_style_state_badge.dart';
import 'package:share_plus/share_plus.dart';

/// One class's link, QR, and share actions.
class LearningStyleLinkCard extends StatelessWidget {
  final String surveyTitle;
  final SurveyGroup group;

  const LearningStyleLinkCard({super.key, required this.surveyTitle, required this.group});

  void _project(BuildContext context, Uint8List qr) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.pop(dialogContext),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$surveyTitle — ${group.name}',
                        textAlign: TextAlign.center, style: TextStylesManager.bold22.copyWith(color: Colors.black)),
                    verticalSpace16,
                    Image.memory(qr, width: 320, height: 320),
                    verticalSpace16,
                    Text(group.url.replaceFirst(RegExp(r'^https?://'), ''),
                        textDirection: TextDirection.ltr, style: TextStylesManager.bold18.copyWith(color: Colors.black)),
                    verticalSpace8,
                    Text(appTranslation().get('learning_styles_tap_to_close'),
                        style: TextStylesManager.regular12.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final qr = qrBytesFromDataUri(group.qr);
    final share = '$surveyTitle — ${group.name}\n${group.url}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(group.name, style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
              ),
              horizontalSpace8,
              LearningStyleStateBadge(state: group.state),
            ],
          ),
          verticalSpace8,
          if (qr != null)
            Container(color: Colors.white, padding: const EdgeInsets.all(6), child: Image.memory(qr, width: 170, height: 170)),
          verticalSpace8,
          SelectableText(group.url,
              textDirection: TextDirection.ltr, style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
          Text('${group.responses} ${appTranslation().get('learning_styles_responses')}',
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
          verticalSpace8,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: ColorsManager.primaryColor),
                icon: const Icon(Icons.share, size: 18),
                label: Text(appTranslation().get('learning_styles_share_link')),
                onPressed: () => SharePlus.instance.share(ShareParams(text: share)),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: Text(appTranslation().get('learning_styles_copy')),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: group.url));
                  if (context.mounted) {
                    showPrimarySnackBar(context, appTranslation().get('learning_styles_copied'), isError: false);
                  }
                },
              ),
              if (qr != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code, size: 18),
                  label: Text(appTranslation().get('learning_styles_share_qr')),
                  onPressed: () => SharePlus.instance.share(ShareParams(
                    files: [XFile.fromData(qr, mimeType: 'image/png', name: 'qr-${group.name}.png')],
                    fileNameOverrides: ['qr-${group.name}.png'],
                    text: share,
                  )),
                ),
              if (qr != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.fullscreen, size: 18),
                  label: Text(appTranslation().get('learning_styles_project')),
                  onPressed: () => _project(context, qr),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

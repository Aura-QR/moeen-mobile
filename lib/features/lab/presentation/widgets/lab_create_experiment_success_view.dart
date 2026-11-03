import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/lab/data/models/lab_experiment_model.dart';
import 'package:share_plus/share_plus.dart';

/// Success view displayed inside [LabCreateExperimentSheet] after creation.
class LabCreateExperimentSuccessView extends StatelessWidget {
  final LabExperimentModel experiment;

  const LabCreateExperimentSuccessView({
    super.key,
    required this.experiment,
  });

  String get _shareUrl =>
      (experiment.url != null && experiment.url!.trim().isNotEmpty)
          ? experiment.url!.trim()
          : 'https://haderedu.com/lab/${experiment.key}';

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _shareUrl));
    if (context.mounted) {
      showPrimarySnackBar(
        context,
        appTranslation().get('lab_create_link_copied'),
      );
    }
  }

  void _shareLink() {
    SharePlus.instance.share(ShareParams(text: _shareUrl));
  }

  void _openExperiment(BuildContext context) {
    AppRouter.pop(experiment, context);
    AppRouter.push(
      Routes.labExperiment,
      arguments: LabExperimentArgs(key: experiment.key, name: experiment.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = appTranslation();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        verticalSpace8,
        Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: ColorsManager.primaryColor,
              size: 40,
            ),
          ),
        ),
        verticalSpace12,
        Text(
          t.get('lab_create_success'),
          textAlign: TextAlign.center,
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
        verticalSpace8,
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorsManager.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            t.get('lab_create_review_notice'),
            textAlign: TextAlign.center,
            style: TextStylesManager.medium13.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
        ),
        verticalSpace12,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ColorsManager.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorsManager.borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _shareUrl,
                  textDirection: TextDirection.ltr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStylesManager.medium13.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
              IconButton(
                tooltip: t.get('lab_create_copy_link'),
                onPressed: () => _copyLink(context),
                icon: Icon(Icons.copy_rounded, color: ColorsManager.primaryColor, size: 20),
              ),
              IconButton(
                tooltip: t.get('lab_share'),
                onPressed: _shareLink,
                icon: Icon(Icons.share_outlined, color: ColorsManager.mainText, size: 20),
              ),
            ],
          ),
        ),
        verticalSpace16,
        PrimaryElevatedButton(
          text: t.get('lab_create_open_experiment'),
          onPressed: () => _openExperiment(context),
        ),
        verticalSpace8,
        TextButton(
          onPressed: () => AppRouter.pop(experiment, context),
          child: Text(
            t.get('lab_create_close'),
            style: TextStylesManager.bold13.copyWith(color: ColorsManager.secondaryText),
          ),
        ),
      ],
    );
  }
}

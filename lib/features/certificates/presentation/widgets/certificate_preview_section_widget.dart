import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';
import 'package:moean/features/certificates/presentation/cubit/certificate_cubit.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_preview_widget.dart';

/// The preview section shown between the template grid and the generate button.
///
/// It wraps [CertificatePreviewWidget] in a [BlocBuilder] so the preview
/// instantly rebuilds whenever the user changes:
///   - template, gender, date, ready-text (cubit states)
///   - any text field (CertificatePreviewUpdated emitted by controller listeners)
class CertificatePreviewSectionWidget extends StatelessWidget {
  const CertificatePreviewSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (prev, curr) =>
          curr is CertificateTemplateSelected ||
          curr is CertificateGenderChanged ||
          curr is CertificateDateChanged ||
          curr is CertificateReadyTextSelected ||
          curr is CertificatePreviewUpdated ||
          curr is CertificateLoaded,
      builder: (context, state) {
        final cubit = CertificateCubit.get(context);
        final template = CertificateTemplateModel.all[cubit.selectedTemplate];
        final data = cubit.buildPreviewData();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ──────────────────────────────────────────
            _PreviewHeaderWidget(template: template, cubit: cubit),
            verticalSpace12,

            // ── Horizontally scrollable certificate canvas ──────────────
            // The inner [CertificatePreviewWidget] enforces a minimum
            // display width of 680 px, so narrow phones can scroll.
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: BoxDecoration(
                    color: ColorsManager.surfacePrimary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ColorsManager.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: CertificatePreviewWidget(
                        availableWidth: constraints.maxWidth - 20, // adjust for padding
                        template: template,
                        data: data,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Header bar: "معاينة الشهادة" label + template name + student count.
class _PreviewHeaderWidget extends StatelessWidget {
  final CertificateTemplateModel template;
  final CertificateCubit cubit;

  const _PreviewHeaderWidget({
    required this.template,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final count = cubit.studentNames.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appTranslation().get('cert_preview_label'),
              style: TextStylesManager.bold12
                  .copyWith(color: ColorsManager.primaryColor),
            ),
            Text(
              '${template.name} — ${template.label}',
              style: TextStylesManager.bold16
                  .copyWith(color: ColorsManager.mainText),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ColorsManager.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${count > 0 ? count : 1} ${appTranslation().get('cert_preview_count_suffix')}',
            style: TextStylesManager.bold12
                .copyWith(color: ColorsManager.primaryColor),
          ),
        ),
      ],
    );
  }
}

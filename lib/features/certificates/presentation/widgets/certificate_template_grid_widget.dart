import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/certificates/data/models/certificate_template_model.dart';
import 'package:moean/features/certificates/presentation/cubit/certificate_cubit.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_template_card_widget.dart';

class CertificateTemplateGridWidget extends StatelessWidget {
  const CertificateTemplateGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (prev, curr) => curr is CertificateTemplateSelected,
      builder: (context, state) {
        final cubit = CertificateCubit.get(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appTranslation().get('cert_choose_template'),
                  style: TextStylesManager.bold14
                      .copyWith(color: ColorsManager.mainText),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${CertificateTemplateModel.all.length} ${appTranslation().get('cert_template_count_suffix')}',
                    style: TextStylesManager.bold12
                        .copyWith(color: ColorsManager.primaryColor),
                  ),
                ),
              ],
            ),
            verticalSpace12,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
              ),
              itemCount: CertificateTemplateModel.all.length,
              itemBuilder: (context, index) {
                final template = CertificateTemplateModel.all[index];
                return Stack(
                  children: [
                    CertificateTemplateCardWidget(
                      template: template,
                      isSelected: cubit.selectedTemplate == index,
                      onTap: () => cubit.selectTemplate(index),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${appTranslation().get('cert_template_label')} ${index + 1}',
                          style: TextStylesManager.bold10
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

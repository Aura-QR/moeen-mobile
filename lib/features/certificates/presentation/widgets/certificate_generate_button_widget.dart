import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/certificates/presentation/cubit/certificate_cubit.dart';

class CertificateGenerateButtonWidget extends StatelessWidget {
  const CertificateGenerateButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (prev, curr) =>
          curr is CertificateGenerating ||
          curr is CertificateLoaded ||
          curr is CertificateError,
      builder: (context, state) {
        final cubit = CertificateCubit.get(context);
        final isGenerating = state is CertificateGenerating;
        final count = cubit.studentNames.length;

        return Column(
          children: [
            if (state is CertificateError)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: ColorsManager.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorsManager.errorColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: ColorsManager.errorColor, size: 18),
                    horizontalSpace8,
                    Expanded(
                      child: Text(
                        state.message == 'no_students'
                            ? appTranslation().get('cert_no_students')
                            : appTranslation().get('cert_error'),
                        style: TextStylesManager.regular12
                            .copyWith(color: ColorsManager.errorColor),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isGenerating ? null : cubit.generatePdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryColor,
                  disabledBackgroundColor:
                      ColorsManager.primaryColor.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: isGenerating
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          horizontalSpace10,
                          Text(
                            appTranslation().get('cert_generating'),
                            style: TextStylesManager.bold16
                                .copyWith(color: ColorsManager.white),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          horizontalSpace10,
                          Text(
                            count > 0
                                ? '${appTranslation().get('cert_generate')} ($count)'
                                : appTranslation().get('cert_generate'),
                            style: TextStylesManager.bold16
                                .copyWith(color: ColorsManager.white),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

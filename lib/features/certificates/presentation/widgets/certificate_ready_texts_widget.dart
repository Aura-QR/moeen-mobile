import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/certificates/presentation/cubit/certificate_cubit.dart';

class CertificateReadyTextsWidget extends StatelessWidget {
  const CertificateReadyTextsWidget({super.key});

  static const List<String> _readyTexts = [
    'لتفوقها الدراسي وسمو أخلاقها، ونتمنى لها دوام التفوق والنجاح بإذن الله.',
    'لتميزه في المشاركة الصفية والانضباط مع تمنياتنا لها بمزيد من التقدم.',
    'لحسن سلوكه وتعاونه مع زملائه ومعلميه، ونتمنى له مزيداً من العطاء.',
    'لالتزامه بالحضور المنتظم وحرصه على التعلم، ونتمنى له التوفيق والسداد.',
    'تقديراً لجهوده المبذولة وإبداعه المتميز في العملية التعليمية.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appTranslation().get('cert_ready_texts'),
          style: TextStylesManager.bold14
              .copyWith(color: ColorsManager.mainText),
        ),
        verticalSpace8,
        ..._readyTexts.map(
          (text) => _ReadyTextItem(text: text),
        ),
      ],
    );
  }
}

class _ReadyTextItem extends StatelessWidget {
  final String text;

  const _ReadyTextItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => CertificateCubit.get(context).selectReadyText(text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ColorsManager.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ColorsManager.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 12,
              color: ColorsManager.primaryColor,
            ),
            horizontalSpace8,
            Expanded(
              child: Text(
                text,
                style: TextStylesManager.regular12
                    .copyWith(color: ColorsManager.mainText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

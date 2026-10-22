import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/thank_you_certificates/presentation/cubit/certificates_cubit.dart';

/// «النص»: the title and the text around `{name}`, prefilled from the reason.
class CertificatesTextSection extends StatelessWidget {
  const CertificatesTextSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = CertificatesCubit.get(context);
    final limits = cubit.state.catalogue.limits;
    return PrimarySectionCard(
      icon: Icons.edit_note_rounded,
      title: appTranslation().get('certificates_section_text'),
      child: ListenableBuilder(
        listenable: Listenable.merge([cubit.titleController, cubit.textController]),
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryTextField(
              controller: cubit.titleController,
              label: appTranslation().get('certificates_field_title'),
              hint: appTranslation().get('certificates_field_title_hint'),
              maxLength: limits.titleChars,
            ),
            verticalSpace12,
            PrimaryTextField(
              controller: cubit.textController,
              label: appTranslation().get('certificates_field_text'),
              hint: appTranslation().get('certificates_name_hint'),
              maxLines: 5,
              maxLength: limits.textChars,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
            verticalSpace6,
            Row(
              children: [
                Expanded(
                  child: Text(
                    appTranslation().get('certificates_name_hint'),
                    style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
                Text(
                  '${cubit.textController.text.length}/${limits.textChars}',
                  style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText),
                ),
              ],
            ),
            verticalSpace8,
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ActionChip(
                  avatar: Icon(Icons.person_pin_outlined, size: 18, color: ColorsManager.primaryColor),
                  label: Text(
                    appTranslation().get('certificates_insert_name'),
                    style: TextStylesManager.medium13.copyWith(color: ColorsManager.primaryColor),
                  ),
                  backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.08),
                  side: BorderSide.none,
                  onPressed: cubit.insertNamePlaceholder,
                ),
                if (cubit.isTextEdited)
                  TextButton.icon(
                    onPressed: cubit.restoreDefaultText,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: Text(appTranslation().get('certificates_restore_text'), style: TextStylesManager.medium13),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

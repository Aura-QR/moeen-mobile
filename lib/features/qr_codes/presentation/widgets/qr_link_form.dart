import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/qr_codes/presentation/cubit/link_qr_cubit.dart';
import 'package:moean/features/qr_codes/presentation/cubit/link_qr_state.dart';

class QrLinkForm extends StatefulWidget {
  const QrLinkForm({super.key});

  @override
  State<QrLinkForm> createState() => _QrLinkFormState();
}

class _QrLinkFormState extends State<QrLinkForm> {
  late final TextEditingController _urlController;
  late final TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    final cubit = LinkQrCubit.get(context);
    _urlController = TextEditingController(text: cubit.state.url);
    _captionController = TextEditingController(text: cubit.state.caption);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LinkQrCubit, LinkQrState>(
      buildWhen: (previous, current) =>
          previous.hasEdited != current.hasEdited ||
          previous.isValid != current.isValid ||
          (previous.logo != null) != (current.logo != null),
      builder: (context, state) {
        final cubit = LinkQrCubit.get(context);
        final showError = state.hasEdited && !state.isValid;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryTextField(
              controller: _urlController,
              label: appTranslation().get('qr_url_label'),
              hint: 'https://haderedu.com',
              keyboardType: TextInputType.url,
              onChanged: (text) => cubit.setUrl(text),
            ),
            if (showError) ...[
              verticalSpace6,
              Text(
                appTranslation().get('qr_url_invalid'),
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.errorColor,
                ),
              ),
            ],
            verticalSpace12,
            PrimaryTextField(
              controller: _captionController,
              label: appTranslation().get('qr_caption_label'),
              hint: appTranslation().get('qr_caption_label'),
              maxLength: 60,
              onChanged: (text) => cubit.setCaption(text),
            ),
            verticalSpace12,
            Row(
              children: [
                if (state.logo == null)
                  OutlinedButton.icon(
                    onPressed: () => cubit.pickLogo(),
                    icon: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 18,
                      color: ColorsManager.primaryColor,
                    ),
                    label: Text(
                      appTranslation().get('qr_add_logo'),
                      style: TextStylesManager.medium13.copyWith(
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ColorsManager.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => cubit.removeLogo(),
                    icon: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: ColorsManager.errorColor,
                    ),
                    label: Text(
                      appTranslation().get('qr_remove_logo'),
                      style: TextStylesManager.medium13.copyWith(
                        color: ColorsManager.errorColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ColorsManager.errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

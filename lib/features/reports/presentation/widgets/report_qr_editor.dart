import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/data/models/report_block.dart';
import 'package:moean/features/reports/data/models/report_block_edits.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';
import 'package:moean/features/reports/presentation/widgets/report_fields_sheet.dart';
import 'package:moean/features/reports/presentation/widgets/report_tap_to_edit.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A QR code for an https link, with a caption under it.
class ReportQrEditor extends StatelessWidget {
  final QrBlock block;

  const ReportQrEditor({super.key, required this.block});

  Future<void> _edit(BuildContext context) async {
    final cubit = ReportEditorCubit.get(context);
    final values = await ReportFieldsSheet.show(context, titleKey: 'report_kind_qr', fields: [
      ReportField(
        label: appTranslation().get('report_qr_url'),
        initialValue: block.url,
        maxLength: 500,
        keyboardType: TextInputType.url,
      ),
      ReportField(label: appTranslation().get('report_qr_caption'), initialValue: block.caption, maxLength: 150),
    ]);
    if (values != null) cubit.updateBlock(block.copyWith(url: values[0].trim(), caption: values[1].trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          padding: const EdgeInsets.all(4),
          color: ColorsManager.surfacePrimary,
          child: isHttpsUrl(block.url)
              ? QrImageView(data: block.url.trim(), padding: EdgeInsets.zero)
              : Icon(Icons.qr_code_2_rounded, size: 48, color: ColorsManager.secondaryText),
        ),
        horizontalSpace12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReportTapToEdit(
                text: block.url,
                placeholderKey: 'report_qr_url_hint',
                style: TextStylesManager.regular12,
                onTap: () => _edit(context),
              ),
              if (block.caption.isNotEmpty) ...[
                verticalSpace4,
                Text(block.caption, style: TextStylesManager.medium13.copyWith(color: ColorsManager.mainText)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

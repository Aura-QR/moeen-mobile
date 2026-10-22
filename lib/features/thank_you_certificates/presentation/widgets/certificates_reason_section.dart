import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/thank_you_certificates/presentation/cubit/certificates_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_picker_tile.dart';

/// «البيانات»: the reason, and an optional date.
class CertificatesReasonSection extends StatelessWidget {
  const CertificatesReasonSection({super.key});

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final cubit = CertificatesCubit.get(context);
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (date != null) cubit.setDate(date);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = CertificatesCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.emoji_events_outlined,
      title: appTranslation().get('certificates_section_data'),
      child: BlocBuilder<CertificatesCubit, CertificatesState>(
        buildWhen: (previous, current) => previous.reason != current.reason || previous.date != current.date,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appTranslation().get('certificates_field_reason'),
              style: TextStylesManager.medium13.copyWith(color: ColorsManager.secondaryText),
            ),
            verticalSpace8,
            PrimaryChoiceChips(
              options: state.catalogue.reasons,
              labelOf: (reason) => reason.label,
              isSelected: (reason) => reason.key == state.reason,
              onTap: (reason) => cubit.setReason(reason.key),
            ),
            verticalSpace16,
            Row(
              children: [
                Expanded(
                  child: DocumentPickerTile(
                    icon: Icons.event_outlined,
                    hint: appTranslation().get('certificates_field_date'),
                    value: state.date == null ? null : isoDate(state.date!),
                    onTap: () => _pickDate(context, state.date),
                  ),
                ),
                if (state.date != null)
                  IconButton(
                    tooltip: appTranslation().get('certificates_date_clear'),
                    onPressed: cubit.clearDate,
                    icon: Icon(Icons.close_rounded, color: ColorsManager.secondaryText),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

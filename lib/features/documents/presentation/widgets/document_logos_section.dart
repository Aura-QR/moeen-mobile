import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/presentation/cubit/document_defaults_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_logo_picker.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';

/// The right and left header logos.
class DocumentLogosSection extends StatelessWidget {
  const DocumentLogosSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimarySectionCard(
      icon: Icons.image_outlined,
      title: appTranslation().get('document_logos'),
      child: BlocBuilder<DocumentDefaultsCubit, DocumentDefaultsState>(
        buildWhen: (previous, current) =>
            previous.logos != current.logos ||
            previous.previews != current.previews ||
            previous.uploadingSlot != current.uploadingSlot,
        builder: (context, state) {
          final cubit = DocumentDefaultsCubit.get(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('document_logos_help'),
                style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace14,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final slot in DocumentLogoSlot.values) ...[
                    if (slot != DocumentLogoSlot.values.first) horizontalSpace12,
                    Expanded(
                      child: DocumentLogoPicker(
                        labelKey: 'document_${slot.jsonKey}',
                        hasLogo: state.logos.containsKey(slot),
                        preview: state.previews[slot],
                        isUploading: state.uploadingSlot == slot,
                        onPick: (source) => cubit.pickLogo(slot, source),
                        onRemove: () => cubit.removeLogo(slot),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

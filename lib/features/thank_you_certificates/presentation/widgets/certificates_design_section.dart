import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/thank_you_certificates/presentation/cubit/certificates_cubit.dart';
import 'package:moean/features/thank_you_certificates/presentation/widgets/certificate_design_tile.dart';

/// «التصميم»: طلاب or طالبات, then one of the designs.
class CertificatesDesignSection extends StatelessWidget {
  const CertificatesDesignSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = CertificatesCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.palette_outlined,
      title: appTranslation().get('certificates_section_design'),
      child: BlocBuilder<CertificatesCubit, CertificatesState>(
        buildWhen: (previous, current) => previous.audience != current.audience || previous.design != current.design,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appTranslation().get('certificates_field_audience'),
              style: TextStylesManager.medium13.copyWith(color: ColorsManager.secondaryText),
            ),
            verticalSpace8,
            PrimaryChoiceChips(
              options: state.catalogue.audiences,
              labelOf: (audience) => audience.label,
              isSelected: (audience) => audience.key == state.audience,
              onTap: (audience) => cubit.setAudience(audience.key),
            ),
            verticalSpace16,
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.catalogue.designs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                // A landscape page plus its name.
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final design = state.catalogue.designs[index];
                return CertificateDesignTile(
                  design: design,
                  isSelected: design.key == state.design,
                  onTap: () => cubit.setDesign(design.key),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

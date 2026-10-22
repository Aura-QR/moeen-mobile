import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/presentation/cubit/document_defaults_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_header_fields.dart';
import 'package:moean/features/documents/presentation/widgets/document_logos_section.dart';
import 'package:moean/features/documents/presentation/widgets/document_option_selector.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';

/// The defaults form: school data, wording and calendar, then the logos.
class DocumentDefaultsBody extends StatelessWidget {
  const DocumentDefaultsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = DocumentDefaultsCubit.get(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        PrimarySectionCard(
          icon: Icons.school_outlined,
          title: appTranslation().get('document_school_data'),
          child: DocumentHeaderFields(controllers: cubit.controllers),
        ),
        verticalSpace16,
        PrimarySectionCard(
          icon: Icons.tune_rounded,
          title: appTranslation().get('document_preferences'),
          child: BlocBuilder<DocumentDefaultsCubit, DocumentDefaultsState>(
            buildWhen: (previous, current) =>
                previous.genderForm != current.genderForm || previous.regionCalendar != current.regionCalendar,
            builder: (context, state) => Column(
              children: [
                DocumentOptionSelector<DocumentGenderForm>(
                  label: appTranslation().get('document_gender_form'),
                  options: DocumentGenderForm.values,
                  selected: state.genderForm,
                  labelKeyOf: (option) => option.labelKey,
                  onChanged: cubit.setGenderForm,
                ),
                verticalSpace16,
                DocumentOptionSelector<DocumentRegionCalendar>(
                  label: appTranslation().get('document_region_calendar'),
                  options: DocumentRegionCalendar.values,
                  selected: state.regionCalendar,
                  labelKeyOf: (option) => option.labelKey,
                  onChanged: cubit.setRegionCalendar,
                ),
              ],
            ),
          ),
        ),
        verticalSpace16,
        const DocumentLogosSection(),
      ],
    );
  }
}

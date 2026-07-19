import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/certificates/presentation/cubit/certificate_cubit.dart';
import 'package:moean/features/certificates/presentation/widgets/certificate_ready_texts_widget.dart';

class CertificateFormWidget extends StatelessWidget {
  const CertificateFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = CertificateCubit.get(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: appTranslation().get('cert_student_names')),
        verticalSpace8,
        PrimaryTextField(
          controller: cubit.studentNamesController,
          hint: appTranslation().get('cert_student_names_hint'),
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        verticalSpace16,
        _SectionLabel(label: appTranslation().get('cert_school_name')),
        verticalSpace8,
        PrimaryTextField(
          controller: cubit.schoolNameController,
          hint: appTranslation().get('cert_school_name'),
        ),
        verticalSpace16,
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: appTranslation().get('cert_director_name')),
                  verticalSpace8,
                  PrimaryTextField(
                    controller: cubit.directorNameController,
                    hint: appTranslation().get('cert_director_name'),
                  ),
                ],
              ),
            ),
            horizontalSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: appTranslation().get('cert_class_name')),
                  verticalSpace8,
                  PrimaryTextField(
                    controller: cubit.classNameController,
                    hint: appTranslation().get('cert_class_name'),
                  ),
                ],
              ),
            ),
          ],
        ),
        verticalSpace16,
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: appTranslation().get('cert_date')),
                  verticalSpace8,
                  _CertDatePickerWidget(),
                ],
              ),
            ),
            horizontalSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: appTranslation().get('cert_teacher_name')),
                  verticalSpace8,
                  PrimaryTextField(
                    controller: cubit.teacherNameController,
                    hint: appTranslation().get('cert_teacher_name'),
                  ),
                ],
              ),
            ),
          ],
        ),
        verticalSpace16,
        _SectionLabel(label: appTranslation().get('cert_text')),
        verticalSpace8,
        PrimaryTextField(
          controller: cubit.certTextController,
          hint: appTranslation().get('cert_text'),
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        verticalSpace16,
        const CertificateReadyTextsWidget(),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStylesManager.bold13.copyWith(color: ColorsManager.mainText),
    );
  }
}

class _CertDatePickerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CertificateCubit, CertificateState>(
      buildWhen: (prev, curr) => curr is CertificateDateChanged,
      builder: (context, state) {
        final cubit = CertificateCubit.get(context);
        final date = cubit.selectedDate;
        final formatted =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        return GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: cubit.selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) cubit.selectDate(picked);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: ColorsManager.surfacePrimary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ColorsManager.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: ColorsManager.primaryColor,
                ),
                horizontalSpace8,
                Expanded(
                  child: Text(
                    formatted,
                    style: TextStylesManager.regular14
                        .copyWith(color: ColorsManager.mainText),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

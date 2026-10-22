import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/formatters/iso_date.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_picker_tile.dart';

/// «البيانات»: المادة، الصف، الفصل، التاريخ، مدة الخطة.
class PlanInfoSection extends StatelessWidget {
  const PlanInfoSection({super.key});

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final cubit = PlanFormCubit.get(context);
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
    final cubit = PlanFormCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.class_outlined,
      title: appTranslation().get('plan_section_info'),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.subjectController,
                  label: appTranslation().get('strategy_field_subject'),
                  hint: appTranslation().get('strategy_field_subject_hint'),
                  maxLength: 120,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.gradeController,
                  label: appTranslation().get('strategy_field_grade'),
                  hint: appTranslation().get('strategy_field_grade_hint'),
                  maxLength: 120,
                ),
              ),
            ],
          ),
          verticalSpace12,
          Row(
            children: [
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.classController,
                  label: appTranslation().get('strategy_field_class'),
                  hint: appTranslation().get('strategy_field_class_hint'),
                  maxLength: 60,
                ),
              ),
              horizontalSpace10,
              Expanded(
                child: PrimaryTextField(
                  controller: cubit.periodController,
                  label: appTranslation().get('plan_field_period'),
                  hint: appTranslation().get('plan_field_period_hint'),
                  maxLength: 120,
                ),
              ),
            ],
          ),
          verticalSpace12,
          BlocSelector<PlanFormCubit, PlanFormState, DateTime?>(
            selector: (state) => state.date,
            builder: (context, date) => DocumentPickerTile(
              icon: Icons.event_outlined,
              hint: appTranslation().get('plan_field_date'),
              value: date == null ? null : isoDate(date),
              onTap: () => _pickDate(context, date),
            ),
          ),
        ],
      ),
    );
  }
}

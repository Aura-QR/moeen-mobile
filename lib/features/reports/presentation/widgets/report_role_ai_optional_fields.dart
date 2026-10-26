import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';

/// Optional context fields (`stage`, `grade`, `date`, `occasion`) for «✨ اكتب لي».
class ReportRoleAiOptionalFields extends StatelessWidget {
  final bool enabled;

  const ReportRoleAiOptionalFields({super.key, required this.enabled});

  Future<void> _pickDate(BuildContext context) async {
    if (!enabled) return;
    final cubit = ReportEditorCubit.get(context);
    final now = DateTime.now();
    final initial = DateTime.tryParse(cubit.dateController.text.trim()) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) cubit.setAiDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryTextField(
                controller: cubit.stageController,
                label: appTranslation().get('role_ai_stage'),
                hint: appTranslation().get('role_ai_stage'),
                enabled: enabled,
                maxLength: 80,
              ),
            ),
            horizontalSpace8,
            Expanded(
              child: PrimaryTextField(
                controller: cubit.gradeController,
                label: appTranslation().get('role_ai_grade'),
                hint: appTranslation().get('role_ai_grade'),
                enabled: enabled,
                maxLength: 80,
              ),
            ),
          ],
        ),
        verticalSpace8,
        Row(
          children: [
            Expanded(
              child: BlocBuilder<ReportEditorCubit, ReportEditorState>(
                buildWhen: (previous, current) => previous.aiDate != current.aiDate,
                builder: (_, state) => PrimaryTextField(
                  controller: cubit.dateController,
                  label: appTranslation().get('role_ai_date'),
                  hint: appTranslation().get('role_ai_date'),
                  enabled: enabled,
                  readOnly: true,
                  onTap: () => _pickDate(context),
                  suffixIcon: state.aiDate.isNotEmpty
                      ? IconButton(
                          onPressed: enabled ? cubit.clearAiDate : null,
                          icon: Icon(Icons.close_rounded, size: 18, color: ColorsManager.secondaryText),
                        )
                      : Icon(Icons.event_outlined, size: 18, color: ColorsManager.secondaryText),
                ),
              ),
            ),
            horizontalSpace8,
            Expanded(
              child: PrimaryTextField(
                controller: cubit.occasionController,
                label: appTranslation().get('role_ai_occasion'),
                hint: appTranslation().get('role_ai_occasion'),
                enabled: enabled,
                maxLength: 120,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

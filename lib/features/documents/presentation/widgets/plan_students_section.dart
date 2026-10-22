import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/student_picker_sheet.dart';

/// «الطلاب المستهدفون»: picked from «فصولي» or typed.
class PlanStudentsSection extends StatelessWidget {
  const PlanStudentsSection({super.key});

  /// Names shown before «+N».
  static const int _previewCount = 8;

  Future<void> _pick(BuildContext context) async {
    final cubit = PlanFormCubit.get(context);
    final result = await StudentPickerSheet.show(
      context,
      initialClassId: cubit.state.classId,
      initialStudents: cubit.state.students,
    );
    if (result != null) cubit.setStudents(result);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return BlocBuilder<PlanFormCubit, PlanFormState>(
      buildWhen: (previous, current) => previous.students != current.students,
      builder: (context, state) {
        final hidden = state.students.length - _previewCount;
        return PrimarySectionCard(
          icon: Icons.groups_2_outlined,
          title: appTranslation().get('plan_section_students'),
          trailing: state.students.isEmpty
              ? null
              : TextButton(
                  onPressed: cubit.clearStudents,
                  child: Text(appTranslation().get('plan_students_clear'), style: TextStylesManager.medium13),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.students.isEmpty
                    ? appTranslation().get('plan_students_empty')
                    : appTranslation().get('class_students_count').replaceAll('{count}', '${state.students.length}'),
                style: TextStylesManager.medium13.copyWith(color: ColorsManager.secondaryText),
              ),
              if (state.students.isNotEmpty) ...[
                verticalSpace10,
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final name in state.students.take(_previewCount))
                      Chip(
                        label: Text(name, style: TextStylesManager.regular12.copyWith(color: ColorsManager.mainText)),
                        backgroundColor: ColorsManager.background,
                        side: BorderSide(color: ColorsManager.borderLightGray),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (hidden > 0)
                      Chip(
                        label: Text('+$hidden', style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor)),
                        backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.08),
                        side: BorderSide.none,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
              verticalSpace8,
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => _pick(context),
                  icon: Icon(state.students.isEmpty ? Icons.person_add_alt_1_outlined : Icons.edit_outlined, size: 20),
                  label: Text(appTranslation().get(state.students.isEmpty ? 'plan_students_pick' : 'plan_students_change')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/features/documents/presentation/cubit/student_picker_cubit.dart';

/// Step 2 of a class pick: its names, all ticked; untick who isn't included.
class StudentPickerNamesView extends StatelessWidget {
  const StudentPickerNamesView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = StudentPickerCubit.get(context);
    return BlocBuilder<StudentPickerCubit, StudentPickerState>(
      buildWhen: (previous, current) =>
          previous.selected != current.selected ||
          previous.classStatus != current.classStatus ||
          previous.checked != current.checked,
      builder: (context, state) {
        final names = state.selected?.students ?? const <String>[];
        final allChecked = state.checkedCount == names.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: appTranslation().get('back'),
                  onPressed: cubit.backToClasses,
                  icon: Icon(Icons.arrow_forward_rounded, color: ColorsManager.mainText),
                ),
                Expanded(
                  child: Text(
                    state.selected?.name ?? '',
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                if (state.classStatus == StudentPickerStatus.success && names.isNotEmpty)
                  TextButton(
                    onPressed: () => cubit.setAll(!allChecked),
                    child: Text(
                      appTranslation().get(allChecked ? 'student_picker_untick_all' : 'student_picker_tick_all'),
                      style: TextStylesManager.medium13,
                    ),
                  ),
              ],
            ),
            if (state.classStatus == StudentPickerStatus.success && names.isNotEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, bottom: 4),
                child: Text(
                  appTranslation()
                      .get('student_picker_ticked')
                      .replaceAll('{count}', '${state.checkedCount}')
                      .replaceAll('{total}', '${names.length}'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
              ),
            Expanded(
              child: ConditionalBuilder(
                loadingState: state.classStatus == StudentPickerStatus.loading,
                errorState: state.classStatus == StudentPickerStatus.failure,
                emptyState: names.isEmpty,
                errorBuilder: (_) => PrimaryErrorView(
                  message: state.errorMessage ?? 'generic_error',
                  onRetry: () => cubit.openClass(state.selected!),
                ),
                emptyBuilder: (_) => NoDataWidget(
                  icon: Icons.person_off_outlined,
                  title: appTranslation().get('student_picker_class_empty'),
                ),
                successBuilder: (_) => ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (context, index) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: state.checked[index],
                    onChanged: (_) => cubit.toggle(index),
                    activeColor: ColorsManager.primaryColor,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      names[index],
                      style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

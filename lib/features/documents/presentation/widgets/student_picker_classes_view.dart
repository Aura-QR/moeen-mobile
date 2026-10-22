import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/documents/presentation/cubit/student_picker_cubit.dart';

/// Step 1 of a class pick: the «فصولي» classes.
class StudentPickerClassesView extends StatelessWidget {
  const StudentPickerClassesView({super.key});

  /// «إدارة فصولي», then reload what changed there.
  Future<void> _manageClasses(BuildContext context) async {
    final cubit = StudentPickerCubit.get(context);
    await Navigator.pushNamed(context, Routes.classes);
    cubit.load();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = StudentPickerCubit.get(context);
    return BlocBuilder<StudentPickerCubit, StudentPickerState>(
      buildWhen: (previous, current) =>
          previous.classesStatus != current.classesStatus || previous.classes != current.classes,
      builder: (context, state) => ConditionalBuilder(
        loadingState: state.classesStatus == StudentPickerStatus.loading,
        errorState: state.classesStatus == StudentPickerStatus.failure,
        emptyState: state.classes.isEmpty,
        errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
        emptyBuilder: (_) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NoDataWidget(
              icon: Icons.groups_2_outlined,
              title: appTranslation().get('student_picker_no_classes'),
              subtitle: appTranslation().get('student_picker_no_classes_subtitle'),
            ),
            TextButton.icon(
              onPressed: () => _manageClasses(context),
              icon: const Icon(Icons.add_rounded),
              label: Text(appTranslation().get('classes_manage')),
            ),
          ],
        ),
        successBuilder: (_) => ListView(
          children: [
            for (final schoolClass in state.classes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.groups_2_outlined, color: ColorsManager.primaryColor),
                ),
                title: Text(
                  schoolClass.name,
                  style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                ),
                subtitle: Text(
                  appTranslation().get('class_students_count').replaceAll('{count}', '${schoolClass.studentsCount}'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
                trailing: Icon(Icons.chevron_left_rounded, color: ColorsManager.secondaryText),
                onTap: () => cubit.openClass(schoolClass),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _manageClasses(context),
                icon: const Icon(Icons.settings_outlined, size: 20),
                label: Text(appTranslation().get('classes_manage')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

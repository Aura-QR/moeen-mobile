import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/documents/data/models/student_picker_result.dart';
import 'package:moean/features/documents/presentation/cubit/student_picker_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_option_selector.dart';
import 'package:moean/features/documents/presentation/widgets/student_picker_classes_view.dart';
import 'package:moean/features/documents/presentation/widgets/student_picker_names_view.dart';
import 'package:moean/features/documents/presentation/widgets/student_picker_typed_view.dart';

/// «الطلاب»: a «فصولي» class (all names ticked) or typed names. Pops with the result.
class StudentPickerSheet extends StatelessWidget {
  const StudentPickerSheet({super.key});

  /// [initialClassId] and [initialStudents] reopen the picker where the form left off.
  static Future<StudentPickerResult?> show(
    BuildContext context, {
    int? initialClassId,
    List<String> initialStudents = const [],
  }) {
    return showModalBottomSheet<StudentPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider(
        create: (_) => StudentPickerCubit(ClassesRepository())
          ..load(initialClassId: initialClassId, initialStudents: initialStudents),
        child: const StudentPickerSheet(),
      ),
    );
  }

  void _done(BuildContext context) {
    final result = StudentPickerCubit.get(context).result();
    if (result == null) {
      showPrimarySnackBar(context, 'student_picker_empty');
      return;
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = StudentPickerCubit.get(context);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12 + MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('student_picker_title'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace12,
              Expanded(
                child: BlocBuilder<StudentPickerCubit, StudentPickerState>(
                  buildWhen: (previous, current) =>
                      previous.mode != current.mode || (previous.selected == null) != (current.selected == null),
                  builder: (context, state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DocumentOptionSelector<StudentPickerMode>(
                        label: appTranslation().get('student_picker_source'),
                        options: StudentPickerMode.values,
                        selected: state.mode,
                        labelKeyOf: (mode) => 'student_picker_mode_${mode.name}',
                        onChanged: cubit.setMode,
                      ),
                      verticalSpace12,
                      Expanded(
                        child: switch (state.mode) {
                          StudentPickerMode.typed => const StudentPickerTypedView(),
                          StudentPickerMode.fromClass when state.selected == null => const StudentPickerClassesView(),
                          StudentPickerMode.fromClass => const StudentPickerNamesView(),
                        },
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpace12,
              PrimaryElevatedButton(
                text: appTranslation().get('student_picker_done'),
                icon: const Icon(Icons.check_rounded),
                onPressed: () => _done(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

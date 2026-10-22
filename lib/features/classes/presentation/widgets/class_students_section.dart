import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_editable_list.dart';
import 'package:moean/core/utils/constants/primary/primary_input_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/presentation/cubit/class_editor_cubit.dart';
import 'package:moean/features/classes/presentation/widgets/class_students_actions.dart';

/// «الطلاب»: paste, import, edit, delete and reorder the names.
class ClassStudentsSection extends StatelessWidget {
  const ClassStudentsSection({super.key});

  Future<void> _paste(BuildContext context) async {
    final cubit = ClassEditorCubit.get(context);
    final values = await PrimaryInputDialog.show(context, titleKey: 'class_paste_names', fields: const [
      PrimaryInputField(hintKey: 'class_paste_names_hint', maxLines: 8, keyboardType: TextInputType.multiline),
    ]);
    if (values != null) cubit.addNames(values.first);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ClassEditorCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.groups_2_outlined,
      title: appTranslation().get('class_section_students'),
      child: BlocBuilder<ClassEditorCubit, ClassEditorState>(
        buildWhen: (previous, current) =>
            previous.students != current.students || previous.isImporting != current.isImporting,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClassStudentsActions(
              isImporting: state.isImporting,
              enabled: !state.isFull,
              onPaste: () => _paste(context),
              onImport: cubit.importFromFile,
            ),
            verticalSpace8,
            Text(
              appTranslation().get('class_names_only_note'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
            verticalSpace16,
            PrimaryEditableList(
              title: appTranslation().get('class_students_list'),
              items: state.students,
              maxItems: ClassLimits.maxStudents,
              maxLength: ClassLimits.maxStudentNameLength,
              addKey: 'class_add_student',
              editKey: 'class_edit_student',
              hintKey: 'class_student_hint',
              onAdd: (name) => cubit.appendNames([name]),
              onEdit: cubit.editStudent,
              onRemove: cubit.removeStudent,
              onReorder: cubit.reorderStudent,
            ),
          ],
        ),
      ),
    );
  }
}

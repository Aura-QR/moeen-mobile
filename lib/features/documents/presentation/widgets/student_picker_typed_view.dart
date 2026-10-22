import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/student_picker_cubit.dart';

/// Typed names, one per line.
class StudentPickerTypedView extends StatelessWidget {
  const StudentPickerTypedView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        PrimaryTextField(
          controller: StudentPickerCubit.get(context).typedController,
          hint: appTranslation().get('class_paste_names_hint'),
          maxLines: 12,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        verticalSpace8,
        Text(
          appTranslation().get('student_picker_typed_note'),
          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
        ),
      ],
    );
  }
}

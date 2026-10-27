import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/document_status_dropdown.dart';
import 'package:moean/features/reading_comprehension/presentation/cubit/reading_editor_cubit.dart';

/// Worksheet settings: name/grade lines, the answer page, and the status.
class ReadingSettingsSheet extends StatelessWidget {
  const ReadingSettingsSheet({super.key});

  static Future<void> show(BuildContext context, {required ReadingEditorCubit cubit}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider.value(value: cubit, child: const ReadingSettingsSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ReadingEditorCubit.get(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: BlocBuilder<ReadingEditorCubit, ReadingEditorState>(
          buildWhen: (p, c) =>
              p.input.studentFields != c.input.studentFields ||
              p.input.showAnswers != c.input.showAnswers ||
              p.documentStatus != c.documentStatus,
          builder: (context, state) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                appTranslation().get('reading_settings_title'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace12,
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: state.input.studentFields,
                activeThumbColor: ColorsManager.primaryColor,
                title: Text(
                  appTranslation().get('reading_student_fields'),
                  style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                ),
                onChanged: cubit.setStudentFields,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: state.input.showAnswers,
                activeThumbColor: ColorsManager.primaryColor,
                title: Text(
                  appTranslation().get('reading_show_answers'),
                  style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                ),
                subtitle: Text(
                  appTranslation().get('reading_show_answers_hint'),
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
                onChanged: cubit.setShowAnswers,
              ),
              verticalSpace8,
              Text(
                appTranslation().get('reading_element_note'),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace12,
              DocumentStatusDropdown(status: state.documentStatus, onChanged: cubit.setDocumentStatus),
            ],
          ),
        ),
      ),
    );
  }
}

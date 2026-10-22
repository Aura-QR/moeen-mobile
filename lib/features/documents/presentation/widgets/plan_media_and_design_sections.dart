import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_images_section.dart';
import 'package:moean/features/documents/presentation/widgets/document_status_dropdown.dart';
import 'package:moean/features/documents/presentation/widgets/document_theme_picker.dart';

/// The end of every plan: «الشواهد», «حالة المستند» and «التصميم».
class PlanMediaAndDesignSections extends StatelessWidget {
  const PlanMediaAndDesignSections({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocBuilder<PlanFormCubit, PlanFormState>(
          buildWhen: (previous, current) =>
              previous.images != current.images || previous.isUploadingImage != current.isUploadingImage,
          builder: (context, state) => DocumentImagesSection(
            images: state.images,
            isUploading: state.isUploadingImage,
            onPick: cubit.addImage,
            onRemove: cubit.removeImage,
          ),
        ),
        verticalSpace14,
        BlocSelector<PlanFormCubit, PlanFormState, String>(
          selector: (state) => state.documentStatus,
          builder: (context, status) => DocumentStatusDropdown(
            // Rebuilds the field when a reopened document brings its status.
            key: ValueKey(status),
            status: status,
            onChanged: cubit.setDocumentStatus,
          ),
        ),
        verticalSpace14,
        BlocSelector<PlanFormCubit, PlanFormState, DocumentTheme>(
          selector: (state) => state.theme,
          builder: (context, theme) => DocumentThemePicker(selected: theme, onChanged: cubit.setTheme),
        ),
      ],
    );
  }
}

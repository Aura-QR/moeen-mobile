import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/presentation/cubit/plan_form_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_media_and_design_sections.dart';

/// The plan's «الشواهد», «حالة المستند» and «التصميم».
class PlanMediaAndDesignSections extends StatelessWidget {
  const PlanMediaAndDesignSections({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = PlanFormCubit.get(context);
    return BlocBuilder<PlanFormCubit, PlanFormState>(
      buildWhen: (previous, current) =>
          previous.images != current.images ||
          previous.isUploadingImage != current.isUploadingImage ||
          previous.documentStatus != current.documentStatus ||
          previous.theme != current.theme,
      builder: (context, state) => DocumentMediaAndDesignSections(
        images: state.images,
        isUploading: state.isUploadingImage,
        onPickImage: cubit.addImage,
        onRemoveImage: cubit.removeImage,
        status: state.documentStatus,
        onStatusChanged: cubit.setDocumentStatus,
        theme: state.theme,
        onThemeChanged: cubit.setTheme,
      ),
    );
  }
}

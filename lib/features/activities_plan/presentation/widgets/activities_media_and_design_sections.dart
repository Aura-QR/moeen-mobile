import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_media_and_design_sections.dart';

/// The plan's «الشواهد», «حالة المستند» and «التصميم».
class ActivitiesMediaAndDesignSections extends StatelessWidget {
  const ActivitiesMediaAndDesignSections({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return BlocBuilder<ActivitiesPlanCubit, ActivitiesPlanState>(
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

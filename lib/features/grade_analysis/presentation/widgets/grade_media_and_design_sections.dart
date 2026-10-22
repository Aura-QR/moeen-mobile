import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/documents/presentation/widgets/document_media_and_design_sections.dart';
import 'package:moean/features/grade_analysis/presentation/cubit/grade_analysis_cubit.dart';

/// The report's «الشواهد», «حالة المستند» and «التصميم».
class GradeMediaAndDesignSections extends StatelessWidget {
  const GradeMediaAndDesignSections({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = GradeAnalysisCubit.get(context);
    return BlocBuilder<GradeAnalysisCubit, GradeAnalysisState>(
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

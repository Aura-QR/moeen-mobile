import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/document_media_and_design_sections.dart';
import 'package:moean/features/reports/presentation/cubit/report_editor_cubit.dart';

/// «الشواهد» (the photos that images blocks pick from), status and design.
/// Sensitive role forms hide the photos panel completely.
class ReportMediaAndDesignSections extends StatelessWidget {
  const ReportMediaAndDesignSections({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ReportEditorCubit.get(context);
    return BlocBuilder<ReportEditorCubit, ReportEditorState>(
      buildWhen: (previous, current) =>
          previous.images != current.images ||
          previous.isUploadingImage != current.isUploadingImage ||
          previous.documentStatus != current.documentStatus ||
          previous.input.theme != current.input.theme ||
          previous.limits.images != current.limits.images ||
          previous.isSensitive != current.isSensitive,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!state.isSensitive) ...[
            Text(
              appTranslation().get('report_photos_hint'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
            verticalSpace8,
          ],
          DocumentMediaAndDesignSections(
            images: state.images,
            isUploading: state.isUploadingImage,
            onPickImage: cubit.addImage,
            onRemoveImage: cubit.removeImage,
            status: state.documentStatus,
            onStatusChanged: cubit.setDocumentStatus,
            theme: state.input.theme,
            onThemeChanged: cubit.setTheme,
            maxImages: state.limits.images,
            showImages: !state.isSensitive,
          ),
        ],
      ),
    );
  }
}

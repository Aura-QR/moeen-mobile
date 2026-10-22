import 'package:flutter/material.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/presentation/widgets/document_images_section.dart';
import 'package:moean/features/documents/presentation/widgets/document_status_dropdown.dart';
import 'package:moean/features/documents/presentation/widgets/document_theme_picker.dart';

/// The end of every document form: «الشواهد», «حالة المستند» and «التصميم».
class DocumentMediaAndDesignSections extends StatelessWidget {
  final List<DocumentImageModel> images;
  final bool isUploading;
  final ValueChanged<DeviceFileSource> onPickImage;
  final ValueChanged<int> onRemoveImage;
  final String status;
  final ValueChanged<String> onStatusChanged;
  final DocumentTheme theme;
  final ValueChanged<DocumentTheme> onThemeChanged;

  const DocumentMediaAndDesignSections({
    super.key,
    required this.images,
    required this.isUploading,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.status,
    required this.onStatusChanged,
    required this.theme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DocumentImagesSection(
          images: images,
          isUploading: isUploading,
          onPick: onPickImage,
          onRemove: onRemoveImage,
        ),
        verticalSpace14,
        DocumentStatusDropdown(
          // Rebuilds the field when a reopened document brings its status.
          key: ValueKey(status),
          status: status,
          onChanged: onStatusChanged,
        ),
        verticalSpace14,
        DocumentThemePicker(selected: theme, onChanged: onThemeChanged),
      ],
    );
  }
}

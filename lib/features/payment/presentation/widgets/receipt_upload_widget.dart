
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class ReceiptUploadWidget extends StatefulWidget {
  final void Function(String filePath, String fileName) onFileSelected;

  const ReceiptUploadWidget({super.key, required this.onFileSelected});

  @override
  State<ReceiptUploadWidget> createState() => _ReceiptUploadWidgetState();
}

class _ReceiptUploadWidgetState extends State<ReceiptUploadWidget> {
  String? _selectedFileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.path == null) return;
    final sizeInMb = (file.size / (1024 * 1024));
    if (sizeInMb > 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appTranslation().get('pay_file_too_large'),
              textAlign: TextAlign.center,
            ),
            backgroundColor: ColorsManager.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }
    setState(() => _selectedFileName = file.name);
    widget.onFileSelected(file.path!, file.name);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedFileName != null
                ? ColorsManager.primaryColor
                : ColorsManager.borderColor,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedFileName != null
                  ? Icons.check_circle_outline
                  : Icons.upload_file_outlined,
              size: 36,
              color: _selectedFileName != null
                  ? ColorsManager.primaryColor
                  : ColorsManager.secondaryText,
            ),
            verticalSpace10,
            Text(
              _selectedFileName ??
                  appTranslation().get('pay_choose_receipt'),
              style: TextStylesManager.medium14.copyWith(
                color: _selectedFileName != null
                    ? ColorsManager.primaryColor
                    : ColorsManager.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFileName == null) ...[
              verticalSpace4,
              Text(
                appTranslation().get('pay_receipt_formats'),
                style: TextStylesManager.regular12.copyWith(
                  color: ColorsManager.secondaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

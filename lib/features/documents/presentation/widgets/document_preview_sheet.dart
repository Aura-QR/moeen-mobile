import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';
import 'package:moean/features/documents/presentation/cubit/document_preview_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_preview_image.dart';

/// «معاينة»: the first page of the form as it is now, rendered as printed.
class DocumentPreviewSheet extends StatelessWidget {
  final String title;

  const DocumentPreviewSheet({super.key, required this.title});

  /// [type] is a DocumentTypes value; [landscape] is the expected page, shown
  /// until the preview arrives.
  static Future<void> show(
    BuildContext context, {
    required String type,
    required Map<String, dynamic> input,
    required String title,
    bool landscape = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider(
        create: (_) => DocumentPreviewCubit(
          type: type,
          repository: DocumentsRepository(),
          fileService: DocumentFileService(),
          landscape: landscape,
        )..render(input),
        child: DocumentPreviewSheet(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
              verticalSpace12,
              const DocumentPreviewImage(),
              verticalSpace8,
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(appTranslation().get('close'), style: TextStylesManager.bold14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

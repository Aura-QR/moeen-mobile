import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';
import 'package:moean/features/documents/presentation/cubit/document_preview_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_preview_image.dart';

/// Zoomable A4-portrait preview of the worksheet (`POST /documents/preview`).
class ReadingPreviewSheet extends StatelessWidget {
  final String title;

  const ReadingPreviewSheet({super.key, required this.title});

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> input,
    required String title,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider(
        create: (_) => DocumentPreviewCubit(
          type: DocumentTypes.readingComprehension,
          repository: DocumentsRepository(),
          fileService: DocumentFileService(),
        )..render(input),
        child: ReadingPreviewSheet(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title.trim().isEmpty ? appTranslation().get('reading_preview') : title,
                style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace4,
              Text(
                appTranslation().get('reading_preview_hint'),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace12,
              Flexible(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: const DocumentPreviewImage(),
                ),
              ),
              verticalSpace8,
              TextButton(
                onPressed: () => AppRouter.pop(null, context),
                child: Text(appTranslation().get('close'), style: TextStylesManager.bold14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

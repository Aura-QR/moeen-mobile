import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';
import 'package:moean/features/documents/presentation/cubit/document_preview_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_preview_image.dart';

/// «معاينة» of one name's certificate, rendered as printed.
class CertificatePreviewSheet extends StatelessWidget {
  final String name;

  const CertificatePreviewSheet({super.key, required this.name});

  /// A4 landscape.
  static const double aspectRatio = 297 / 210;

  /// [input] is the certificate for [name] alone.
  static Future<void> show(BuildContext context, {required String name, required Map<String, dynamic> input}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider(
        create: (_) => DocumentPreviewCubit(
          type: DocumentTypes.certificates,
          repository: DocumentsRepository(),
          fileService: DocumentFileService(),
        )..render(input),
        child: CertificatePreviewSheet(name: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appTranslation().get('certificates_preview_of').replaceAll('{name}', name),
              style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
            ),
            verticalSpace12,
            const DocumentPreviewImage(aspectRatio: aspectRatio),
            verticalSpace8,
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(appTranslation().get('close'), style: TextStylesManager.bold14),
            ),
          ],
        ),
      ),
    );
  }
}

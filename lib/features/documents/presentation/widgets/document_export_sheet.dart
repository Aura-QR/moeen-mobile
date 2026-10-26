import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';
import 'package:moean/features/documents/presentation/cubit/document_element_cubit.dart';
import 'package:moean/features/documents/presentation/cubit/document_export_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_element_tile.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:moean/features/documents/presentation/widgets/document_export_error_widget.dart';
import 'package:moean/features/documents/presentation/widgets/document_export_option.dart';

/// PDF, image, Word (and Excel where tables matter) and print for a saved document.
class DocumentExportSheet extends StatelessWidget {
  final bool withExcel;

  /// «يُحسب شاهدًا لـ» at the top; off for the performance file itself.
  final bool withElement;

  /// A note under the title, e.g. where the file's content comes from.
  final String? noteKey;

  const DocumentExportSheet({super.key, this.withExcel = false, this.withElement = true, this.noteKey});

  static Future<void> show(
    BuildContext context, {
    required int documentId,
    bool withExcel = false,
    bool withElement = true,
    String? noteKey,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => DocumentExportCubit(
              documentId: documentId,
              repository: DocumentsRepository(),
              fileService: DocumentFileService(),
            ),
          ),
          if (withElement)
            BlocProvider(
              create: (_) => DocumentElementCubit(
                documentId: documentId,
                documents: DocumentsRepository(),
                portfolios: PortfolioRepository(),
              )..load(),
            ),
        ],
        child: DocumentExportSheet(withExcel: withExcel, withElement: withElement, noteKey: noteKey),
      ),
    );
  }

  static final _options = [
    (DocumentExportAction.pdf, Icons.picture_as_pdf_rounded, ColorsManager.errorColor, 'document_export_pdf'),
    (DocumentExportAction.image, Icons.image_outlined, ColorsManager.whatsappIconColor, 'document_export_image'),
    (DocumentExportAction.word, Icons.description_rounded, ColorsManager.emailIconColor, 'document_export_word'),
    (DocumentExportAction.excel, Icons.table_chart_rounded, ColorsManager.primaryColor, 'document_export_excel'),
    (DocumentExportAction.print, Icons.print_outlined, ColorsManager.textBody, 'document_export_print'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: BlocBuilder<DocumentExportCubit, DocumentExportState>(
          buildWhen: (previous, current) =>
              previous.activeAction != current.activeAction || previous.errorMessage != current.errorMessage,
          builder: (context, state) {
            final cubit = DocumentExportCubit.get(context);
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get('document_export_title'),
                  style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
                ),
                if (noteKey != null) ...[
                  verticalSpace4,
                  Text(
                    appTranslation().get(noteKey!),
                    style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
                  ),
                ],
                if (withElement) ...[
                  verticalSpace12,
                  const DocumentElementTile(),
                ],
                verticalSpace16,
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                  children: [
                    for (final (action, icon, color, key) in _options)
                      if (withExcel || action != DocumentExportAction.excel)
                      DocumentExportOption(
                        icon: icon,
                        color: color,
                        title: appTranslation().get(key),
                        subtitle: appTranslation().get(
                          state.activeAction == action ? 'document_export_preparing' : '${key}_note',
                        ),
                        isLoading: state.activeAction == action,
                        onTap: state.isBusy ? null : () => cubit.run(action),
                      ),
                  ],
                ),
                if (state.errorMessage != null) ...[
                  verticalSpace12,
                  DocumentExportErrorWidget(message: state.errorMessage!, onRetry: cubit.retry),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

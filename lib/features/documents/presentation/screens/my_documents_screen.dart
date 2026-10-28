import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/cubit/my_documents_cubit.dart';
import 'package:moean/features/documents/presentation/document_tools.dart';
import 'package:moean/features/documents/presentation/widgets/document_export_sheet.dart';
import 'package:moean/features/documents/presentation/widgets/document_type_filter_bar.dart';
import 'package:moean/features/documents/presentation/widgets/my_documents_list.dart';
import 'package:moean/features/documents/presentation/widgets/new_document_sheet.dart';

/// F3 «مستنداتي».
class MyDocumentsScreen extends StatelessWidget {
  const MyDocumentsScreen({super.key});

  /// Opens the tool and refreshes on return, since the title may change.
  Future<void> _openTool(BuildContext context, DocumentTool tool, {int? documentId}) async {
    final cubit = MyDocumentsCubit.get(context);
    await Navigator.pushNamed(context, tool.route, arguments: documentId);
    cubit.load();
  }

  void _open(BuildContext context, DocumentModel document) {
    // Built from the portfolio, so there's no form: only its files.
    if (document.type == DocumentTypes.performanceFile) {
      DocumentExportSheet.show(
        context,
        documentId: document.id,
        withElement: false,
        noteKey: 'performance_file_note',
      );
      return;
    }
    // L3 «أنماط التعلم»: server-built report, no editor; only its files.
    if (document.type == DocumentTypes.learningStyles) {
      DocumentExportSheet.show(
        context,
        documentId: document.id,
        noteKey: 'learning_styles_report_note',
      );
      return;
    }
    final tool = documentToolFor(document.type);
    if (tool == null) {
      showPrimarySnackBar(context, 'document_type_unsupported');
      return;
    }
    _openTool(context, tool, documentId: document.id);
  }

  Future<void> _create(BuildContext context) async {
    final tool = documentTools.length == 1 ? documentTools.first : await NewDocumentSheet.show(context);
    if (tool != null && context.mounted) _openTool(context, tool);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = MyDocumentsCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('my_documents_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocListener<MyDocumentsCubit, MyDocumentsState>(
        listenWhen: (_, current) => current.feedback != null,
        listener: (context, state) =>
            showPrimarySnackBar(context, state.feedback!.message, isError: state.feedback!.isError),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: PrimaryTextField(
                controller: cubit.searchController,
                hint: appTranslation().get('document_search_hint'),
                textInputAction: TextInputAction.search,
                prefixIcon: Icon(Icons.search_rounded, color: ColorsManager.secondaryText),
                onChanged: cubit.onSearchChanged,
              ),
            ),
            const DocumentTypeFilterBar(),
            verticalSpace12,
            Expanded(
              child: BlocBuilder<MyDocumentsCubit, MyDocumentsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.documents.isEmpty != current.documents.isEmpty,
                builder: (context, state) => ConditionalBuilder(
                  loadingState: state.status == MyDocumentsStatus.loading,
                  errorState: state.status == MyDocumentsStatus.failure,
                  emptyState: state.documents.isEmpty,
                  errorBuilder: (_) => PrimaryErrorView(
                    message: state.errorMessage ?? 'generic_error',
                    onRetry: cubit.load,
                  ),
                  emptyBuilder: (_) => NoDataWidget(
                    icon: Icons.folder_open_outlined,
                    title: appTranslation().get('my_documents_empty_title'),
                    subtitle: appTranslation().get('my_documents_empty_subtitle'),
                  ),
                  successBuilder: (_) => MyDocumentsList(onOpen: (document) => _open(context, document)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Builder(
          builder: (context) => PrimaryElevatedButton(
            text: appTranslation().get('document_new'),
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _create(context),
          ),
        ),
      ),
    );
  }
}

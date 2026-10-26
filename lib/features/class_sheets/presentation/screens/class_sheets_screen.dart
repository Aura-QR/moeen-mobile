import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/class_sheets/data/repositories/class_sheets_repository.dart';
import 'package:moean/features/class_sheets/presentation/cubit/class_sheets_cubit.dart';
import 'package:moean/features/class_sheets/presentation/cubit/class_sheets_state.dart';
import 'package:moean/features/class_sheets/presentation/widgets/sheet_class_selector.dart';
import 'package:moean/features/class_sheets/presentation/widgets/sheet_columns_editor.dart';
import 'package:moean/features/class_sheets/presentation/widgets/sheet_kind_selector.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';
import 'package:moean/features/documents/presentation/cubit/document_preview_cubit.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';
import 'package:moean/features/documents/presentation/widgets/document_preview_image.dart';
import 'package:moean/features/documents/presentation/widgets/document_preview_sheet.dart';

class ClassSheetsScreen extends StatelessWidget {
  final int? documentId;
  final SchoolClassModel? initialClass;

  const ClassSheetsScreen({
    super.key,
    this.documentId,
    this.initialClass,
  });

  static Widget create({int? documentId, SchoolClassModel? initialClass}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DocumentPreviewCubit>(
          create: (_) => DocumentPreviewCubit(
            type: DocumentTypes.classSheet,
            repository: DocumentsRepository(),
            fileService: DocumentFileService(),
          ),
        ),
        BlocProvider<ClassSheetsCubit>(
          create: (context) {
            final previewCubit = BlocProvider.of<DocumentPreviewCubit>(context);
            final cubit = ClassSheetsCubit(
              repository: ClassSheetsRepository(),
              classesRepository: ClassesRepository(),
              documentsRepository: DocumentsRepository(),
              documentId: documentId,
              initialClass: initialClass,
              previewCubit: previewCubit,
            );
            cubit.init();
            return cubit;
          },
        ),
      ],
      child: ClassSheetsScreen(documentId: documentId, initialClass: initialClass),
    );
  }

  Future<void> _onStateChange(BuildContext context, ClassSheetsState state) async {
    final cubit = ClassSheetsCubit.get(context);
    final feedback = state.feedbackMessage;
    if (feedback != null) {
      showPrimarySnackBar(context, feedback, isError: state.isErrorFeedback);
      cubit.clearFeedback();
    }

    final followUp = state.followUp;
    final docId = state.savedDocumentId;
    if (followUp != null && docId != null) {
      cubit.clearFollowUp();
      await runDocumentFollowUp(
        context,
        followUp: followUp,
        documentId: docId,
        documentType: DocumentTypes.classSheet,
        portfolioItemKey: 'class_sheets',
      );
    }
  }

  void _showPreview(BuildContext context, ClassSheetsState state) {
    DocumentPreviewSheet.show(
      context,
      type: DocumentTypes.classSheet,
      input: state.input.toJson(),
      title: appTranslation().get(state.selectedKind.label),
      landscape: state.isLandscape,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ClassSheetsCubit.get(context);

    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('sheets_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
        actions: [
          BlocBuilder<ClassSheetsCubit, ClassSheetsState>(
            builder: (context, state) => IconButton(
              icon: Icon(Icons.preview_rounded, color: ColorsManager.primaryColor),
              tooltip: appTranslation().get('sheets_preview'),
              onPressed: () => _showPreview(context, state),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ClassSheetsCubit, ClassSheetsState>(
        listenWhen: (previous, current) =>
            previous.feedbackMessage != current.feedbackMessage ||
            previous.followUp != current.followUp,
        listener: _onStateChange,
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.kinds != current.kinds ||
            previous.selectedKind != current.selectedKind ||
            previous.classes != current.classes ||
            previous.isLoadingClasses != current.isLoadingClasses ||
            previous.input != current.input,
        builder: (context, state) {
          return ConditionalBuilder(
            loadingState: state.isLoading && state.kinds.isEmpty,
            errorState: state.status == ClassSheetsStatus.failure && state.kinds.isEmpty,
            emptyState: false,
            errorBuilder: (_) => PrimaryErrorView(
              message: state.errorMessage ?? 'generic_error',
              onRetry: cubit.init,
            ),
            successBuilder: (_) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SheetKindSelector(
                    kinds: state.kinds,
                    selectedKind: state.selectedKind,
                    onSelected: cubit.selectKind,
                  ),
                  verticalSpace16,
                  SheetClassSelector(
                    input: state.input,
                    classes: state.classes,
                    isLoadingClasses: state.isLoadingClasses,
                    onToggleEmptyRows: cubit.setUseEmptyRows,
                    onSelectClass: cubit.selectClass,
                    onUpdateEmptyRows: cubit.setEmptyRows,
                    onUpdateSubject: cubit.updateSubject,
                    onUpdateGrade: cubit.updateGrade,
                    onUpdateTerm: cubit.updateTerm,
                    onUpdateTitle: cubit.updateTitle,
                  ),
                  verticalSpace16,
                  SheetColumnsEditor(
                    kind: state.selectedKind,
                    input: state.input,
                    onUpdateStartDate: cubit.updateStartDate,
                    onUpdateWeeks: cubit.updateWeeks,
                    onUpdateFollowUpDate: cubit.updateFollowUpDate,
                    onReorderColumns: cubit.reorderColumns,
                    onAddColumn: cubit.addColumn,
                    onUpdateColumn: cubit.updateColumn,
                    onRemoveColumn: cubit.removeColumn,
                    onResetColumns: cubit.resetColumns,
                  ),
                  verticalSpace16,

                  // Preview Card Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorsManager.surfacePrimary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorsManager.borderColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                Icons.remove_red_eye_outlined,
                                color: ColorsManager.primaryColor,
                                size: 18,
                              ),
                            ),
                            horizontalSpace10,
                            Expanded(
                              child: Text(
                                appTranslation().get('sheets_preview'),
                                style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showPreview(context, state),
                              style: TextButton.styleFrom(
                                backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.08),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: Icon(
                                Icons.zoom_out_map_rounded,
                                size: 15,
                                color: ColorsManager.primaryColor,
                              ),
                              label: Text(
                                'تكبير المعاينة',
                                style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                              ),
                            ),
                          ],
                        ),
                        verticalSpace12,
                        const DocumentPreviewImage(),
                      ],
                    ),
                  ),
                  verticalSpace32,
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ClassSheetsCubit, ClassSheetsState>(
        buildWhen: (previous, current) =>
            previous.isSaving != current.isSaving ||
            previous.status != current.status,
        builder: (context, state) => DocumentActionsBar(
          enabled: !state.isSaving,
          isSaving: state.isSaving,
          onSave: () => cubit.save(),
          onExport: () => cubit.save(followUp: DocumentFollowUp.export),
          onAttach: () => cubit.save(followUp: DocumentFollowUp.attachToPortfolio),
        ),
      ),
    );
  }
}

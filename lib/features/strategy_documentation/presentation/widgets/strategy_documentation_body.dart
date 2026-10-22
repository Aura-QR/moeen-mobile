import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/widgets/document_header_section.dart';
import 'package:moean/features/documents/presentation/widgets/document_media_and_design_sections.dart';
import 'package:moean/features/documents/presentation/widgets/document_notes_section.dart';
import 'package:moean/features/strategy_documentation/presentation/cubit/strategy_documentation_cubit.dart';
import 'package:moean/features/strategy_documentation/presentation/widgets/strategy_content_section.dart';
import 'package:moean/features/strategy_documentation/presentation/widgets/strategy_lesson_section.dart';
import 'package:moean/features/strategy_documentation/presentation/widgets/strategy_picker_section.dart';

/// The form's sections, in the order the document prints them.
class StrategyDocumentationBody extends StatelessWidget {
  const StrategyDocumentationBody({super.key});

  /// Defaults change the header of every document, so reload them on return.
  Future<void> _editDefaults(BuildContext context) async {
    final cubit = StrategyDocumentationCubit.get(context);
    final saved = await Navigator.pushNamed(context, Routes.documentDefaults);
    if (saved == true) cubit.reloadDefaults();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = StrategyDocumentationCubit.get(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const StrategyPickerSection(),
        verticalSpace14,
        const StrategyLessonSection(),
        verticalSpace14,
        BlocBuilder<StrategyDocumentationCubit, StrategyDocumentationState>(
          buildWhen: (previous, current) =>
              previous.defaults != current.defaults || previous.isOverridingHeader != current.isOverridingHeader,
          builder: (context, state) => DocumentHeaderSection(
            defaults: state.defaults,
            isOverriding: state.isOverridingHeader,
            overrideControllers: cubit.header.controllers,
            onOverrideChanged: cubit.setHeaderOverride,
            onEditDefaults: () => _editDefaults(context),
          ),
        ),
        verticalSpace14,
        const StrategyContentSection(),
        verticalSpace14,
        DocumentNotesSection(controller: cubit.notesController),
        verticalSpace14,
        BlocBuilder<StrategyDocumentationCubit, StrategyDocumentationState>(
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
        ),
      ],
    );
  }
}

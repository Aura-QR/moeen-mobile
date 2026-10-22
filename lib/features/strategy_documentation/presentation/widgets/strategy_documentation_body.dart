import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_theme.dart';
import 'package:moean/features/documents/presentation/widgets/document_header_section.dart';
import 'package:moean/features/documents/presentation/widgets/document_images_section.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/features/documents/presentation/widgets/document_status_dropdown.dart';
import 'package:moean/features/documents/presentation/widgets/document_theme_picker.dart';
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
        PrimarySectionCard(
          icon: Icons.sticky_note_2_outlined,
          title: appTranslation().get('strategy_section_notes'),
          child: PrimaryTextField(
            controller: cubit.notesController,
            hint: appTranslation().get('strategy_notes_hint'),
            maxLines: 4,
            maxLength: 2000,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ),
        verticalSpace14,
        BlocBuilder<StrategyDocumentationCubit, StrategyDocumentationState>(
          buildWhen: (previous, current) =>
              previous.images != current.images || previous.isUploadingImage != current.isUploadingImage,
          builder: (context, state) => DocumentImagesSection(
            images: state.images,
            isUploading: state.isUploadingImage,
            onPick: cubit.addImage,
            onRemove: cubit.removeImage,
          ),
        ),
        verticalSpace14,
        BlocSelector<StrategyDocumentationCubit, StrategyDocumentationState, String>(
          selector: (state) => state.documentStatus,
          builder: (context, status) => DocumentStatusDropdown(
            // Rebuilds the field when a reopened document brings its status.
            key: ValueKey(status),
            status: status,
            onChanged: cubit.setDocumentStatus,
          ),
        ),
        verticalSpace14,
        BlocSelector<StrategyDocumentationCubit, StrategyDocumentationState, DocumentTheme>(
          selector: (state) => state.theme,
          builder: (context, theme) => DocumentThemePicker(selected: theme, onChanged: cubit.setTheme),
        ),
      ],
    );
  }
}

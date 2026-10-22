import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/classes/presentation/cubit/class_editor_cubit.dart';
import 'package:moean/features/classes/presentation/widgets/class_import_review_sheet.dart';
import 'package:moean/features/classes/presentation/widgets/class_info_section.dart';
import 'package:moean/features/classes/presentation/widgets/class_students_section.dart';

/// A class in «فصولي». Pops with true after a save.
class ClassEditorScreen extends StatelessWidget {
  const ClassEditorScreen({super.key});

  Future<void> _onEvent(BuildContext context, ClassEditorState state) async {
    final feedback = state.feedback;
    if (feedback != null) showPrimarySnackBar(context, feedback.message, isError: feedback.isError);
    if (state.isSaved) {
      Navigator.pop(context, true);
      return;
    }

    final imported = state.importedNames;
    if (imported == null) return;
    final cubit = ClassEditorCubit.get(context);
    if (await ClassImportReviewSheet.show(context, imported)) cubit.appendNames(imported);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ClassEditorCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get(cubit.state.classId == null ? 'class_new' : 'class_edit'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocConsumer<ClassEditorCubit, ClassEditorState>(
        listenWhen: (_, current) => current.feedback != null || current.importedNames != null || current.isSaved,
        listener: _onEvent,
        // Sections rebuild their own parts; this only switches load states.
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == ClassEditorStatus.loading,
          errorState: state.status == ClassEditorStatus.failure,
          errorBuilder: (_) => PrimaryErrorView(message: state.errorMessage ?? 'generic_error', onRetry: cubit.load),
          successBuilder: (_) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const ClassInfoSection(),
              verticalSpace14,
              const ClassStudentsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: BlocBuilder<ClassEditorCubit, ClassEditorState>(
          buildWhen: (previous, current) => previous.status != current.status || previous.isSaving != current.isSaving,
          builder: (context, state) => PrimaryElevatedButton(
            text: appTranslation().get('save'),
            icon: const Icon(Icons.save_outlined, size: 20),
            isLoading: state.isSaving,
            onPressed: state.status == ClassEditorStatus.success && !state.isSaving ? cubit.save : null,
          ),
        ),
      ),
    );
  }
}

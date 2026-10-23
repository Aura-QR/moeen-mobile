import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/document_follow_up.dart';
import 'package:moean/features/documents/presentation/widgets/document_actions_bar.dart';
import 'package:moean/features/preparation_print/data/models/preparation_print_models.dart';
import 'package:moean/features/preparation_print/presentation/cubit/preparation_print_cubit.dart';

/// «طباعة التحضير»: edit the prepared lessons, then print, Word or add to the portfolio.
class PreparationPrintScreen extends StatelessWidget {
  const PreparationPrintScreen({super.key});

  static Widget create(int documentId) => BlocProvider(
        create: (_) => PreparationPrintCubit(documentId: documentId, documents: DocumentsRepository())..load(),
        child: const PreparationPrintScreen(),
      );

  Future<void> _onChange(BuildContext context, PreparationPrintState state) async {
    final cubit = PreparationPrintCubit.get(context);
    if (state.feedback != null) {
      showPrimarySnackBar(context, state.feedback!, isError: state.isErrorFeedback);
      cubit.clearFeedback();
    }
    if (state.followUp != null) {
      final followUp = state.followUp;
      cubit.clearFollowUp();
      await runDocumentFollowUp(
        context,
        followUp: followUp,
        documentId: cubit.documentId,
        documentType: DocumentTypes.lessonPreparation,
        portfolioItemKey: 'learning_plan',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PreparationPrintCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(appTranslation().get('prep_print_title'), style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
      ),
      body: BlocConsumer<PreparationPrintCubit, PreparationPrintState>(
        listenWhen: (a, b) => a.feedback != b.feedback || a.followUp != b.followUp,
        listener: _onChange,
        // The fields keep their own text; rebuild only when the document loads.
        buildWhen: (a, b) => a.isLoading != b.isLoading || a.error != b.error,
        builder: (context, state) {
          if (state.isLoading) return const Center(child: CircularProgressIndicator());
          if (state.error != null) return PrimaryErrorView(message: state.error!, onRetry: cubit.load);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(appTranslation().get('prep_print_hint'), style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText)),
              verticalSpace12,
              for (var i = 0; i < state.lessons.length; i++) ...[
                _LessonCard(index: i, lesson: state.lessons[i], numbered: state.lessons.length > 1),
                verticalSpace12,
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<PreparationPrintCubit, PreparationPrintState>(
        buildWhen: (a, b) => a.isSaving != b.isSaving || a.isLoading != b.isLoading,
        builder: (context, state) => DocumentActionsBar(
          enabled: !state.isSaving && !state.isLoading && state.error == null,
          isSaving: state.isSaving,
          onSave: () => cubit.save(),
          onExport: () => cubit.save(followUp: DocumentFollowUp.export),
          onAttach: () => cubit.save(followUp: DocumentFollowUp.attachToPortfolio),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int index;
  final PrintLesson lesson;
  final bool numbered;

  const _LessonCard({required this.index, required this.lesson, required this.numbered});

  @override
  Widget build(BuildContext context) {
    final cubit = PreparationPrintCubit.get(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderLightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: lesson.text('lesson_title'),
            maxLength: 200,
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
            decoration: InputDecoration(labelText: numbered ? '${index + 1}. ${appTranslation().get('prep_print_lesson_title')}' : appTranslation().get('prep_print_lesson_title'), counterText: ''),
            onChanged: (v) => cubit.updateTitle(index, v),
          ),
          for (final section in PrintSection.all) ...[
            verticalSpace10,
            TextFormField(
              initialValue: lesson.text(section.key),
              minLines: 2,
              maxLines: 8,
              maxLength: section.isList ? 6000 : 3000,
              style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
              decoration: InputDecoration(
                labelText: appTranslation().get(section.labelKey),
                helperText: section.isList ? appTranslation().get('prep_print_one_per_line') : null,
                counterText: '',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (v) => cubit.updateText(index, section, v),
            ),
          ],
        ],
      ),
    );
  }
}

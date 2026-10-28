import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/outcomes_map/data/models/outcomes_map_editor_args.dart';
import 'package:moean/features/outcomes_map/presentation/cubit/outcomes_maps_cubit.dart';
import 'package:moean/features/outcomes_map/presentation/widgets/outcomes_maps_list_view.dart';

/// L9 «خريطة نواتج التعلم»: saved maps (`GET /documents?type=outcomes_map`) and «خريطة جديدة».
class OutcomesMapsScreen extends StatelessWidget {
  const OutcomesMapsScreen({super.key});

  Future<void> _openEditor(BuildContext context, Object? arguments) async {
    final cubit = OutcomesMapsCubit.get(context);
    await AppRouter.push(AppRouter.outcomesMapEditor, arguments: arguments, context: context);
    cubit.load();
  }

  void _openDocument(BuildContext context, DocumentModel document) =>
      _openEditor(context, OutcomesMapEditorArgs(documentId: document.id));

  Future<void> _createNew(BuildContext context) async {
    final args = await AppRouter.push<OutcomesMapEditorArgs>(
      AppRouter.outcomesMapNew,
      context: context,
    );
    if (args != null && context.mounted) {
      await _openEditor(context, args);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = OutcomesMapsCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('outcomes_map_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocListener<OutcomesMapsCubit, OutcomesMapsState>(
        listenWhen: (_, current) => current.feedback != null,
        listener: (context, state) => showPrimarySnackBar(
          context,
          state.feedback!.message,
          isError: state.feedback!.isError,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: PrimaryElevatedButton(
                text: appTranslation().get('outcomes_map_new'),
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _createNew(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: PrimaryTextField(
                controller: cubit.searchController,
                hint: appTranslation().get('document_search_hint'),
                textInputAction: TextInputAction.search,
                prefixIcon: Icon(Icons.search_rounded, color: ColorsManager.secondaryText),
                onChanged: cubit.onSearchChanged,
              ),
            ),
            Expanded(
              child: BlocBuilder<OutcomesMapsCubit, OutcomesMapsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.documents.isEmpty != current.documents.isEmpty,
                builder: (context, state) => ConditionalBuilder(
                  loadingState: state.status == OutcomesMapsStatus.loading,
                  errorState: state.status == OutcomesMapsStatus.failure,
                  emptyState: state.documents.isEmpty,
                  errorBuilder: (_) => PrimaryErrorView(
                    message: state.errorMessage ?? 'generic_error',
                    onRetry: cubit.load,
                  ),
                  emptyBuilder: (_) => NoDataWidget(
                    icon: Icons.list_alt_outlined,
                    title: appTranslation().get('outcomes_map_empty_title'),
                    subtitle: appTranslation().get('outcomes_map_empty_subtitle'),
                  ),
                  successBuilder: (_) => OutcomesMapsListView(
                    onOpen: (doc) => _openDocument(context, doc),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

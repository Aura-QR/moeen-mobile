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
import 'package:moean/features/concept_maps/data/models/concept_map_editor_args.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_maps_cubit.dart';
import 'package:moean/features/concept_maps/presentation/widgets/concept_maps_list_view.dart';
import 'package:moean/features/documents/data/models/document_model.dart';

/// L9 «خرائط المفاهيم»: saved concept maps (`GET /documents?type=concept_map`) and «خريطة جديدة».
class ConceptMapsScreen extends StatelessWidget {
  const ConceptMapsScreen({super.key});

  Future<void> _openEditor(BuildContext context, Object? arguments) async {
    final cubit = ConceptMapsCubit.get(context);
    await AppRouter.push(
      AppRouter.conceptMapsEditor,
      arguments: arguments,
      context: context,
    );
    cubit.load();
  }

  void _openDocument(BuildContext context, DocumentModel document) =>
      _openEditor(context, ConceptMapEditorArgs(documentId: document.id));

  Future<void> _createNew(BuildContext context) async {
    final args = await AppRouter.push<ConceptMapEditorArgs>(
      AppRouter.conceptMapsNew,
      context: context,
    );
    if (args != null && context.mounted) {
      await _openEditor(context, args);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ConceptMapsCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('concept_maps_title'),
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
      ),
      body: BlocListener<ConceptMapsCubit, ConceptMapsState>(
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
                text: appTranslation().get('concept_map_new'),
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
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: ColorsManager.secondaryText,
                ),
                onChanged: cubit.onSearchChanged,
              ),
            ),
            Expanded(
              child: BlocBuilder<ConceptMapsCubit, ConceptMapsState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status ||
                    previous.documents.isEmpty != current.documents.isEmpty,
                builder: (context, state) => ConditionalBuilder(
                  loadingState: state.status == ConceptMapsStatus.loading,
                  errorState: state.status == ConceptMapsStatus.failure,
                  emptyState: state.documents.isEmpty,
                  errorBuilder: (_) => PrimaryErrorView(
                    message: state.errorMessage ?? 'generic_error',
                    onRetry: cubit.load,
                  ),
                  emptyBuilder: (_) => NoDataWidget(
                    icon: Icons.account_tree_outlined,
                    title: appTranslation().get('concept_maps_empty_title'),
                    subtitle: appTranslation().get(
                      'concept_maps_empty_subtitle',
                    ),
                  ),
                  successBuilder: (_) => ConceptMapsListView(
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/concept_maps/presentation/cubit/concept_maps_cubit.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/widgets/document_card_widget.dart';
import 'package:moean/features/documents/presentation/widgets/document_element_sheet.dart';

/// Paginated list of saved concept maps with swipe-to-delete and card actions.
class ConceptMapsListView extends StatelessWidget {
  final ValueChanged<DocumentModel> onOpen;

  const ConceptMapsListView({super.key, required this.onOpen});

  Future<bool> _confirmDelete(BuildContext context) => showPrimaryConfirmDialog(
    context,
    titleKey: 'document_delete',
    messageKey: 'document_delete_confirm',
  );

  Future<bool> _swipeDelete(
    BuildContext context,
    DocumentModel document,
  ) async {
    final cubit = ConceptMapsCubit.get(context);
    if (await _confirmDelete(context)) await cubit.deleteDocument(document.id);
    return false;
  }

  Future<void> _onAction(
    BuildContext context,
    DocumentModel document,
    DocumentCardAction action,
  ) async {
    final cubit = ConceptMapsCubit.get(context);
    if (action == DocumentCardAction.element) {
      final changed = await DocumentElementSheet.showForDocument(
        context,
        documentId: document.id,
        element: document.element,
      );
      if (changed) await cubit.load();
    } else if (action == DocumentCardAction.duplicate) {
      await cubit.duplicate(document.id);
    } else if (await _confirmDelete(context)) {
      await cubit.deleteDocument(document.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ConceptMapsCubit.get(context);
    return BlocBuilder<ConceptMapsCubit, ConceptMapsState>(
      buildWhen: (previous, current) =>
          previous.documents != current.documents ||
          previous.isLoadingMore != current.isLoadingMore ||
          previous.busyDocumentId != current.busyDocumentId,
      builder: (context, state) => NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 300) cubit.loadMore();
          return false;
        },
        child: RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: state.documents.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) => verticalSpace10,
            itemBuilder: (context, index) {
              if (index == state.documents.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final document = state.documents[index];
              return Dismissible(
                key: ValueKey(document.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _swipeDelete(context, document),
                background: Container(
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: ColorsManager.errorColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: ColorsManager.errorColor,
                  ),
                ),
                child: DocumentCardWidget(
                  document: document,
                  isBusy: state.busyDocumentId == document.id,
                  onTap: () => onOpen(document),
                  onAction: (action) => _onAction(context, document, action),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

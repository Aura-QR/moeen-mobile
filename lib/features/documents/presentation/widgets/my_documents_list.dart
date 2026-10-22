import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/presentation/cubit/my_documents_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_card_widget.dart';

/// The documents, loading the next page near the end. Swipe to delete.
class MyDocumentsList extends StatelessWidget {
  final ValueChanged<DocumentModel> onOpen;

  const MyDocumentsList({super.key, required this.onOpen});

  Future<bool> _confirmDelete(BuildContext context) => showPrimaryConfirmDialog(
        context,
        titleKey: 'document_delete',
        messageKey: 'document_delete_confirm',
      );

  /// Deletes through the cubit and returns false: the row leaves when the
  /// list updates, and stays if the delete fails.
  Future<bool> _swipeDelete(BuildContext context, DocumentModel document) async {
    final cubit = MyDocumentsCubit.get(context);
    if (await _confirmDelete(context)) await cubit.delete(document);
    return false;
  }

  Future<void> _onAction(BuildContext context, DocumentModel document, DocumentCardAction action) async {
    final cubit = MyDocumentsCubit.get(context);
    if (action == DocumentCardAction.duplicate) {
      await cubit.duplicate(document);
    } else if (await _confirmDelete(context)) {
      await cubit.delete(document);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = MyDocumentsCubit.get(context);
    return BlocBuilder<MyDocumentsCubit, MyDocumentsState>(
      buildWhen: (previous, current) =>
          previous.documents != current.documents ||
          previous.isLoadingMore != current.isLoadingMore ||
          previous.busyId != current.busyId,
      builder: (context, state) => NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 300) cubit.loadMore();
          return false;
        },
        child: RefreshIndicator(
          onRefresh: cubit.load,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            itemCount: state.documents.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, _) => verticalSpace10,
            itemBuilder: (context, index) {
              if (index == state.documents.length) {
                return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
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
                  child: const Icon(Icons.delete_outline_rounded, color: ColorsManager.errorColor),
                ),
                child: DocumentCardWidget(
                  document: document,
                  isBusy: state.busyId == document.id,
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

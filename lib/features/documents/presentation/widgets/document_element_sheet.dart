import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/presentation/cubit/document_element_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/document_element_option_tile.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

/// Picks the element a document counts for, or «لا يُحسب شاهدًا». Pops with
/// true once the change is saved.
class DocumentElementSheet extends StatelessWidget {
  const DocumentElementSheet({super.key});

  /// With the cubit of a [DocumentElementTile] already on screen.
  static Future<bool> open(BuildContext context, DocumentElementCubit cubit) => _show(
        context,
        BlocProvider.value(value: cubit, child: const DocumentElementSheet()),
      );

  /// For a document row whose element is already known.
  static Future<bool> showForDocument(BuildContext context, {required int documentId, String? element}) => _show(
        context,
        BlocProvider(
          create: (_) => DocumentElementCubit(
            documentId: documentId,
            documents: DocumentsRepository(),
            portfolios: PortfolioRepository(),
            element: element,
            elementKnown: true,
          )..load(),
          child: const DocumentElementSheet(),
        ),
      );

  static Future<bool> _show(BuildContext context, Widget sheet) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => sheet,
    );
    return changed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = DocumentElementCubit.get(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: BlocConsumer<DocumentElementCubit, DocumentElementState>(
          listenWhen: (_, current) => current.changed || current.feedback?.isError == true,
          listener: (context, state) {
            if (state.changed) {
              Navigator.pop(context, true);
            } else {
              showPrimarySnackBar(context, state.feedback!.message);
            }
          },
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.element != current.element ||
              previous.isSaving != current.isSaving,
          builder: (context, state) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                child: Text(
                  appTranslation().get('document_element_title'),
                  style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  appTranslation().get('document_element_hint'),
                  style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
                ),
              ),
              verticalSpace8,
              Flexible(
                child: ConditionalBuilder(
                  loadingState: state.status == DocumentElementStatus.loading,
                  errorState: state.status == DocumentElementStatus.failure,
                  emptyState: false,
                  loadingBuilder: (_) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorBuilder: (_) => PrimaryErrorView(
                    message: state.errorMessage ?? 'generic_error',
                    onRetry: cubit.load,
                  ),
                  successBuilder: (_) => ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    children: [
                      DocumentElementOptionTile(
                        title: appTranslation().get('document_element_none'),
                        isSelected: state.element == null,
                        enabled: !state.isSaving,
                        onTap: () => cubit.change(null),
                      ),
                      for (final element in state.elements.elements)
                        DocumentElementOptionTile(
                          title: element.title,
                          number: element.number,
                          isSelected: state.element == element.key,
                          enabled: !state.isSaving,
                          onTap: () => cubit.change(element.key),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

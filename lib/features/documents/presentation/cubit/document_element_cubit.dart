import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/portfolio/data/models/portfolio_element_model.dart';
import 'package:moean/features/portfolio/data/repositories/portfolio_repository.dart';

part 'document_element_state.dart';

/// «يُحسب شاهدًا لـ»: the portfolio element a saved document counts for (T9).
class DocumentElementCubit extends Cubit<DocumentElementState> {
  static DocumentElementCubit get(BuildContext context) => BlocProvider.of(context);

  /// Pass [element] when it's already known (a list row); otherwise the
  /// document is fetched for it.
  DocumentElementCubit({
    required this.documentId,
    required DocumentsRepository documents,
    required PortfolioRepository portfolios,
    String? element,
    bool elementKnown = false,
  })  : _documents = documents,
        _portfolios = portfolios,
        _elementKnown = elementKnown,
        super(DocumentElementState(element: element));

  final int documentId;
  final DocumentsRepository _documents;
  final PortfolioRepository _portfolios;
  final bool _elementKnown;

  Future<void> load() async {
    emit(state.copyWith(status: DocumentElementStatus.loading));
    final elementsRequest = _portfolios.getElements();
    final documentRequest = _elementKnown ? null : _documents.getDocument(documentId);
    final elements = await elementsRequest;
    final document = await documentRequest;
    if (isClosed) return;

    final failure = elements.fold((f) => f, (_) => null) ?? document?.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: DocumentElementStatus.failure, errorMessage: failure.message));
      return;
    }
    emit(DocumentElementState(
      status: DocumentElementStatus.ready,
      elements: elements.fold((_) => const PortfolioElementsModel(elements: []), (e) => e),
      element: document == null ? state.element : document.fold((_) => null, (doc) => doc.element),
    ));
  }

  /// [element] null keeps the document out of the performance file.
  Future<void> change(String? element) async {
    if (element == state.element || state.isSaving) return;
    emit(state.copyWith(isSaving: true));
    final result = await _documents.setElement(documentId, element);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, feedback: UiFeedback(failure.message))),
      (document) => emit(state.copyWith(
        isSaving: false,
        element: document.element,
        clearElement: document.element == null,
        changed: true,
        feedback: const UiFeedback('document_element_saved', isError: false),
      )),
    );
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_model.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';

part 'document_preview_state.dart';

/// The first page of a document as an image, for the form as it is now
/// (`POST /documents/preview`, nothing saved): the HTML is turned into a
/// PDF and its first page into a PNG on the phone, so it looks as printed.
class DocumentPreviewCubit extends Cubit<DocumentPreviewState> {
  static DocumentPreviewCubit get(BuildContext context) => BlocProvider.of(context);

  DocumentPreviewCubit({
    required this.type,
    required DocumentsRepository repository,
    required DocumentFileService fileService,
    Duration debounce = const Duration(milliseconds: 600),
  }) : _repo = repository,
       _files = fileService,
       _debounce = debounce,
       super(const DocumentPreviewState());

  /// A [DocumentTypes] value.
  final String type;
  final DocumentsRepository _repo;
  final DocumentFileService _files;
  final Duration _debounce;
  Timer? _timer;

  /// Only the latest render may land; earlier ones are for an older form.
  int _request = 0;

  /// Renders [input] once the form has been still for the debounce time.
  void schedule(Map<String, dynamic> input) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => render(input));
  }

  Future<void> render(Map<String, dynamic> input) async {
    _timer?.cancel();
    final request = ++_request;
    emit(state.copyWith(status: DocumentPreviewStatus.loading));
    final result = await _image(input);
    if (isClosed || request != _request) return;
    result.fold(
      (failure) => emit(state.copyWith(status: DocumentPreviewStatus.failure, errorMessage: failure.message)),
      (image) => emit(DocumentPreviewState(status: DocumentPreviewStatus.success, image: image)),
    );
  }

  Future<Either<Failure, Uint8List>> _image(Map<String, dynamic> input) async {
    final page = await _repo.previewDocument(type, input);
    return page.fold(Left.new, (page) async {
      final pdf = await _files.htmlToPdf(page.html, landscape: DocumentTypes.isLandscape(type));
      return pdf.fold(Left.new, _files.firstPageAsPng);
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

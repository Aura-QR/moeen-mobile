import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/documents/data/models/document_export_models.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';
import 'package:moean/features/documents/data/services/document_file_service.dart';

part 'document_export_state.dart';

/// The export sheet: PDF and image are made on the phone from the print
/// HTML; Word is built on the server queue. The document must be saved first.
class DocumentExportCubit extends Cubit<DocumentExportState> {
  static DocumentExportCubit get(BuildContext context) => BlocProvider.of(context);

  DocumentExportCubit({
    required this.documentId,
    this.landscape = false,
    required DocumentsRepository repository,
    required DocumentFileService fileService,
    Duration pollInterval = const Duration(seconds: 2),
    int maxPollAttempts = 30,
  })  : _repo = repository,
        _files = fileService,
        _pollInterval = pollInterval,
        _maxPollAttempts = maxPollAttempts,
        super(const DocumentExportState());

  final int documentId;

  /// The page size the print HTML sets ([DocumentTypes.isLandscape]).
  final bool landscape;
  final DocumentsRepository _repo;
  final DocumentFileService _files;
  final Duration _pollInterval;

  /// 30 × 2 s = the 60 s the API doc allows for a Word file.
  final int _maxPollAttempts;

  /// The PDF is made once per sheet; the document can't change while it's open.
  ({Uint8List bytes, String name})? _pdf;

  Future<void> run(DocumentExportAction action) async {
    if (state.activeAction != null) return;
    emit(DocumentExportState(activeAction: action));
    final result = switch (action) {
      DocumentExportAction.pdf => _sharePdf(),
      DocumentExportAction.image => _shareImage(),
      DocumentExportAction.print => _print(),
      DocumentExportAction.word => _shareWord(),
    };
    final outcome = await result;
    if (isClosed) return;
    outcome.fold(
      (failure) => emit(DocumentExportState(failedAction: action, errorMessage: failure.message)),
      (_) => emit(const DocumentExportState()),
    );
  }

  Future<void> retry() async {
    final action = state.failedAction;
    if (action != null) await run(action);
  }

  Future<Either<Failure, Unit>> _sharePdf() async {
    final pdf = await _loadPdf();
    return pdf.fold(
      Left.new,
      (pdf) => _files.share(pdf.bytes, fileName: '${pdf.name}.pdf', mime: DocumentFileService.pdfMime),
    );
  }

  Future<Either<Failure, Unit>> _print() async {
    final pdf = await _loadPdf();
    return pdf.fold(Left.new, (pdf) => _files.printPdf(pdf.bytes, name: '${pdf.name}.pdf'));
  }

  Future<Either<Failure, Unit>> _shareImage() async {
    final pdf = await _loadPdf();
    return pdf.fold(Left.new, (pdf) async {
      final png = await _files.firstPageAsPng(pdf.bytes);
      return png.fold(
        Left.new,
        (bytes) => _files.share(bytes, fileName: '${pdf.name}.png', mime: DocumentFileService.pngMime),
      );
    });
  }

  Future<Either<Failure, ({Uint8List bytes, String name})>> _loadPdf() async {
    final cached = _pdf;
    if (cached != null) return Right(cached);

    final printPage = await _repo.getPrint(documentId);
    return printPage.fold(Left.new, (page) async {
      final bytes = await _files.htmlToPdf(page.html, landscape: landscape);
      return bytes.map((data) => _pdf = (bytes: data, name: page.fileName));
    });
  }

  Future<Either<Failure, Unit>> _shareWord() async {
    final export = await _waitForWord();
    return export.fold(Left.new, (export) async {
      final bytes = await _repo.downloadFile(export.url ?? '');
      return bytes.fold(
        Left.new,
        (data) => _files.share(data, fileName: export.fileName, mime: DocumentFileService.docxMime),
      );
    });
  }

  /// Requests the Word file, then polls until it's done or failed.
  Future<Either<Failure, DocumentExportModel>> _waitForWord() async {
    final requested = await _repo.requestExport(documentId, DocumentExportFormat.docx);
    return requested.fold(Left.new, (first) async {
      var export = first;
      for (var attempt = 0; export.isPending; attempt++) {
        if (attempt >= _maxPollAttempts || isClosed) {
          return const Left(ServerFailure('document_export_timeout'));
        }
        await Future<void>.delayed(_pollInterval);
        final next = await _repo.getExport(documentId, export.id);
        final failure = next.fold<Failure?>((failure) => failure, (polled) {
          export = polled;
          return null;
        });
        if (failure != null) return Left(failure);
      }
      if (export.isFailed) return Left(ServerFailure(export.error ?? 'document_export_failed'));
      return Right(export);
    });
  }
}

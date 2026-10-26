import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/qr_codes/data/services/qr_export_service.dart';
import 'package:moean/features/qr_codes/presentation/cubit/qr_export_state.dart';
import 'package:printing/printing.dart';

class QrExportCubit extends Cubit<QrExportState> {
  final QrExportService _service;

  QrExportCubit({QrExportService? service})
      : _service = service ?? QrExportService(),
        super(const QrExportState());

  static QrExportCubit get(BuildContext context) => BlocProvider.of(context);

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }

  Future<void> saveToGallery({
    required Uint8List png,
    required String name,
  }) async {
    emit(state.copyWith(isExporting: true, clearMessage: true));

    final success = await _service.saveToGallery(png, name);
    if (isClosed) return;

    emit(state.copyWith(
      isExporting: false,
      message: success ? 'qr_saved' : 'qr_save_failed',
      isSuccess: success,
    ));
  }

  Future<void> shareImage({
    required Uint8List png,
    required String link,
    String? filename,
  }) async {
    emit(state.copyWith(isExporting: true, clearMessage: true));
    try {
      await _service.sharePng(png, link: link, filename: filename);
    } catch (_) {}
    if (!isClosed) {
      emit(state.copyWith(isExporting: false));
    }
  }

  Future<void> sharePdf({
    required Uint8List qrPng,
    String? caption,
    required String link,
  }) async {
    emit(state.copyWith(isExporting: true, clearMessage: true));
    try {
      final bytes = await _service.pdfBytes(
        qrPng: qrPng,
        caption: caption,
        link: link,
      );
      await Printing.sharePdf(bytes: bytes, filename: 'qr.pdf');
    } catch (_) {}
    if (!isClosed) {
      emit(state.copyWith(isExporting: false));
    }
  }

  Future<void> printPdf({
    required Uint8List qrPng,
    String? caption,
    required String link,
  }) async {
    emit(state.copyWith(isExporting: true, clearMessage: true));
    try {
      final bytes = await _service.pdfBytes(
        qrPng: qrPng,
        caption: caption,
        link: link,
      );
      await Printing.layoutPdf(onLayout: (_) => bytes);
    } catch (_) {}
    if (!isClosed) {
      emit(state.copyWith(isExporting: false));
    }
  }
}

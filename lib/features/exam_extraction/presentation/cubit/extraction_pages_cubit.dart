import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/exam_extraction/data/models/extraction_page_model.dart';
import 'package:moean/features/exam_extraction/presentation/cubit/extraction_pages_state.dart';

class ExtractionPagesCubit extends Cubit<ExtractionPagesState> {
  final ImagePicker _imagePicker;
  final DeviceFilePicker _filePicker;

  ExtractionPagesCubit({
    ImagePicker? imagePicker,
    DeviceFilePicker? filePicker,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _filePicker = filePicker ?? DeviceFilePicker(),
        super(const ExtractionPagesState());

  static ExtractionPagesCubit get(BuildContext context) =>
      BlocProvider.of(context);

  static const int maxPages = 6;
  static const int maxPhotoBytes = 4 * 1024 * 1024; // 4 MB
  static const int maxPdfBytes = 10 * 1024 * 1024; // 10 MB

  bool get canStart => state.canStart;

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void setCount(int count) {
    emit(state.copyWith(count: count.clamp(1, 40), clearError: true));
  }

  void setNotes(String? notes) {
    if (notes == null) {
      emit(state.copyWith(notes: null, clearError: true));
    } else {
      final trimmed = notes.length > 500 ? notes.substring(0, 500) : notes;
      emit(state.copyWith(notes: trimmed, clearError: true));
    }
  }

  void removePage(int index) {
    if (index < 0 || index >= state.pages.length) return;
    final updated = List<ExtractionPageModel>.from(state.pages)..removeAt(index);
    emit(state.copyWith(pages: updated, clearError: true));
  }

  Future<void> addFromCamera() async {
    if (state.pages.any((p) => p.isPdf)) {
      emit(state.copyWith(error: 'exam_extract_no_mix'));
      return;
    }
    if (state.pages.length >= maxPages) {
      emit(state.copyWith(error: 'exam_extract_max_pages'));
      return;
    }

    final xFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    if (bytes.length > maxPhotoBytes) {
      emit(state.copyWith(error: 'exam_extract_photo_too_big'));
      return;
    }

    final fileName = xFile.name.isNotEmpty
        ? xFile.name
        : (xFile.path.isNotEmpty
            ? xFile.path.split(RegExp(r'[\\/]')).last
            : 'photo.jpg');
    final mime = DevicePickedFile.mimeFromName(fileName) ?? 'image/jpeg';
    final page = ExtractionPageModel(
      bytes: bytes,
      name: fileName,
      mime: mime,
    );

    emit(state.copyWith(
      pages: [...state.pages, page],
      clearError: true,
    ));
  }

  Future<void> addFromGallery() async {
    if (state.pages.any((p) => p.isPdf)) {
      emit(state.copyWith(error: 'exam_extract_no_mix'));
      return;
    }
    final remaining = maxPages - state.pages.length;
    if (remaining <= 0) {
      emit(state.copyWith(error: 'exam_extract_max_pages'));
      return;
    }

    final xFiles = await _imagePicker.pickMultiImage(
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
      limit: remaining,
    );
    if (xFiles.isEmpty) return;

    final toProcess = xFiles.take(remaining).toList();
    final newPages = <ExtractionPageModel>[];
    bool hasOversized = false;

    for (final file in toProcess) {
      final bytes = await file.readAsBytes();
      if (bytes.length > maxPhotoBytes) {
        hasOversized = true;
        continue;
      }
      final fileName = file.name.isNotEmpty
          ? file.name
          : (file.path.isNotEmpty
              ? file.path.split(RegExp(r'[\\/]')).last
              : 'photo.jpg');
      final mime = DevicePickedFile.mimeFromName(fileName) ?? 'image/jpeg';
      newPages.add(ExtractionPageModel(
        bytes: bytes,
        name: fileName,
        mime: mime,
      ));
    }

    emit(state.copyWith(
      pages: [...state.pages, ...newPages],
      error: hasOversized ? 'exam_extract_photo_too_big' : null,
      clearError: !hasOversized,
    ));
  }

  Future<void> pickPdf() async {
    final picked = await _filePicker.pick(DeviceFileSource.pdf);
    if (picked == null) return;

    if (picked.byteSize > maxPdfBytes) {
      emit(state.copyWith(error: 'exam_extract_pdf_too_big'));
      return;
    }

    final page = ExtractionPageModel(
      bytes: picked.bytes,
      name: picked.name,
      mime: 'application/pdf',
    );

    emit(state.copyWith(
      pages: [page],
      clearError: true,
    ));
  }
}

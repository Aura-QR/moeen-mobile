import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/documents/data/models/document_defaults_model.dart';
import 'package:moean/features/documents/data/models/document_upload_rules.dart';
import 'package:moean/features/documents/data/repositories/documents_repository.dart';

part 'document_defaults_state.dart';

/// F2: the header data typed once and used by every document.
class DocumentDefaultsCubit extends Cubit<DocumentDefaultsState> {
  static DocumentDefaultsCubit get(BuildContext context) => BlocProvider.of(context);

  DocumentDefaultsCubit({
    required DocumentsRepository repository,
    required DeviceFilePicker filePicker,
  })  : _repo = repository,
        _picker = filePicker,
        super(const DocumentDefaultsState());

  final DocumentsRepository _repo;
  final DeviceFilePicker _picker;

  final Map<DocumentHeaderField, TextEditingController> controllers = {
    for (final field in DocumentHeaderField.values) field: TextEditingController(),
  };

  /// Prefills the form from `resolved`, so account data shows up too.
  Future<void> load() async {
    emit(state.copyWith(status: DocumentDefaultsStatus.loading));
    final result = await _repo.getDefaults();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: DocumentDefaultsStatus.failure, errorMessage: failure.message)),
      (defaults) {
        for (final field in DocumentHeaderField.values) {
          controllers[field]!.text = defaults.text(field);
        }
        emit(state.copyWith(
          status: DocumentDefaultsStatus.success,
          genderForm: defaults.genderForm,
          regionCalendar: defaults.regionCalendar,
          logos: defaults.logos,
        ));
      },
    );
  }

  void setGenderForm(DocumentGenderForm value) => emit(state.copyWith(genderForm: value));

  void setRegionCalendar(DocumentRegionCalendar value) => emit(state.copyWith(regionCalendar: value));

  Future<void> pickLogo(DocumentLogoSlot slot, DeviceFileSource source) async {
    final file = await _picker.pick(source);
    if (file == null || isClosed) return;

    final error = DocumentUploadRules.validate(file);
    if (error != null) {
      emit(state.copyWith(feedback: UiFeedback(error)));
      return;
    }

    emit(state.copyWith(uploadingSlot: slot));
    final result = await _repo.uploadImage(file);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(clearUploading: true, feedback: UiFeedback(failure.message))),
      (path) => emit(state.copyWith(
        clearUploading: true,
        logos: {...state.logos, slot: path},
        previews: {...state.previews, slot: file.bytes},
      )),
    );
  }

  void removeLogo(DocumentLogoSlot slot) {
    emit(state.copyWith(
      logos: {...state.logos}..remove(slot),
      previews: {...state.previews}..remove(slot),
    ));
  }

  Future<void> save() async {
    if (state.isSaving || state.uploadingSlot != null) return;
    emit(state.copyWith(isSaving: true));
    final result = await _repo.saveDefaults(DocumentDefaultsModel(
      texts: {
        for (final entry in controllers.entries)
          if (entry.value.text.trim().isNotEmpty) entry.key: entry.value.text.trim(),
      },
      genderForm: state.genderForm,
      regionCalendar: state.regionCalendar,
      logos: state.logos,
    ));
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(isSaving: false, feedback: UiFeedback(failure.message))),
      (_) => emit(state.copyWith(isSaving: false, saved: true)),
    );
  }

  @override
  Future<void> close() {
    for (final controller in controllers.values) {
      controller.dispose();
    }
    return super.close();
  }
}

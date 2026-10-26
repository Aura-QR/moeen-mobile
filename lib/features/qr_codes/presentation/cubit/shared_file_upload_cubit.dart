import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/core/models/upload_models.dart';
import 'package:moean/core/services/device_file_picker.dart';
import 'package:moean/features/qr_codes/data/repositories/shared_files_repository.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_file_upload_state.dart';

class SharedFileUploadCubit extends Cubit<SharedFileUploadState> {
  final SharedFilesRepository _repository;
  final DeviceFilePicker _filePicker;
  CancelToken? _cancelToken;

  SharedFileUploadCubit({
    required SharedFilesRepository repository,
    DeviceFilePicker? filePicker,
  })  : _repository = repository,
        _filePicker = filePicker ?? DeviceFilePicker(),
        super(const SharedFileUploadState());

  static SharedFileUploadCubit get(BuildContext context) =>
      BlocProvider.of(context);

  void clearError() {
    emit(state.copyWith(clearError: true, clearPaymentRequired: true));
  }

  Future<void> loadMeta() async {
    emit(state.copyWith(status: SharedFileUploadStatus.loadingMeta));

    final result = await _repository.getFiles();
    if (isClosed) return;

    result.fold(
      (failure) {
        if (failure is PaymentRequiredFailure) {
          emit(state.copyWith(
            status: SharedFileUploadStatus.failed,
            paymentRequired: failure,
            error: failure.message,
          ));
        } else {
          emit(state.copyWith(
            status: SharedFileUploadStatus.failed,
            error: failure.message,
          ));
        }
      },
      (data) {
        emit(state.copyWith(
          status: SharedFileUploadStatus.ready,
          meta: data.meta,
          expiryDays: data.meta.defaultExpiryDays,
          clearError: true,
        ));
      },
    );
  }

  Future<void> pickFileFromDevice() async {
    if (!await _ensureMeta()) return;
    final file = await _filePicker.pickFilePath(state.meta.extensions);
    _setPickedFile(file);
  }

  Future<void> pickMediaFromGallery() async {
    if (!await _ensureMeta()) return;
    final file = await _filePicker.pickMediaPath();
    _setPickedFile(file);
  }

  /// The accepted types and limits come from `meta`; without them nothing can be checked.
  Future<bool> _ensureMeta() async {
    if (state.meta.types.isNotEmpty) return true;
    await loadMeta();
    return state.meta.types.isNotEmpty;
  }

  void _setPickedFile(DevicePickedPath? file) {
    if (file == null) return;

    final mime = state.meta.mimeForExtension(file.extension);
    if (mime == null) {
      emit(state.copyWith(error: 'qr_error_type'));
      return;
    }

    if (file.byteSize > state.meta.maxFileBytes) {
      emit(state.copyWith(error: 'qr_error_too_big'));
      return;
    }

    final remainingQuota = state.meta.quotaBytes - state.meta.usedBytes;
    if (state.meta.quotaBytes > 0 && file.byteSize > remainingQuota) {
      emit(state.copyWith(error: 'qr_error_quota'));
      return;
    }

    emit(state.copyWith(
      file: file,
      mime: mime,
      clearError: true,
      clearPaymentRequired: true,
    ));
  }

  void setTitle(String? title) {
    final trimmed = (title != null && title.length > 120)
        ? title.substring(0, 120)
        : title;
    emit(state.copyWith(title: trimmed, clearError: true));
  }

  void setExpiryDays(int days) {
    emit(state.copyWith(expiryDays: days, clearError: true));
  }

  Future<void> upload() async {
    if (!state.canUpload) return;

    emit(state.copyWith(
      status: SharedFileUploadStatus.uploading,
      progress: 0.0,
      clearError: true,
      clearPaymentRequired: true,
    ));

    _cancelToken = CancelToken();

    final result = await _repository.upload(
      file: state.file!,
      mime: state.mime!,
      title: state.title,
      expiresInDays: state.expiryDays,
      // One emit per percent: Dio reports every chunk, thousands for a 100 MB video.
      onProgress: (p) {
        if (!isClosed && (p * 100).floor() != (state.progress * 100).floor()) {
          emit(state.copyWith(progress: p));
        }
      },
      cancelToken: _cancelToken,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (failure is PaymentRequiredFailure) {
          emit(state.copyWith(
            status: SharedFileUploadStatus.failed,
            paymentRequired: failure,
            error: failure.message,
          ));
        } else {
          emit(state.copyWith(
            status: SharedFileUploadStatus.failed,
            error: failure.message,
          ));
        }
      },
      (fileModel) {
        emit(state.copyWith(
          status: SharedFileUploadStatus.done,
          result: fileModel,
        ));
      },
    );
  }

  void cancel() {
    _cancelToken?.cancel();
    emit(state.copyWith(
      status: SharedFileUploadStatus.ready,
      progress: 0.0,
      clearError: true,
    ));
  }
}

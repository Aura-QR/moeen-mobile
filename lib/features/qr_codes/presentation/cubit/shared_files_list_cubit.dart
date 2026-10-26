import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/errors/failures.dart';
import 'package:moean/features/qr_codes/data/models/shared_file_model.dart';
import 'package:moean/features/qr_codes/data/repositories/shared_files_repository.dart';
import 'package:moean/features/qr_codes/presentation/cubit/shared_files_list_state.dart';

class SharedFilesListCubit extends Cubit<SharedFilesListState> {
  final SharedFilesRepository _repository;

  SharedFilesListCubit({required SharedFilesRepository repository})
      : _repository = repository,
        super(const SharedFilesListState());

  static SharedFilesListCubit get(BuildContext context) =>
      BlocProvider.of(context);

  void clearError() {
    emit(state.copyWith(clearError: true, clearPaymentRequired: true));
  }

  void clearSelectedFile() {
    emit(state.copyWith(clearSelectedFile: true));
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _repository.getFiles();
    if (isClosed) return;

    result.fold(
      (failure) {
        if (failure is PaymentRequiredFailure) {
          emit(state.copyWith(
            isLoading: false,
            paymentRequired: failure,
            error: failure.message,
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            error: failure.message,
          ));
        }
      },
      (data) {
        emit(state.copyWith(
          isLoading: false,
          files: data.files,
          meta: data.meta,
          clearError: true,
        ));
      },
    );
  }

  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true, clearError: true));

    final result = await _repository.getFiles();
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(state.copyWith(
          isRefreshing: false,
          error: failure.message,
        ));
      },
      (data) {
        emit(state.copyWith(
          isRefreshing: false,
          files: data.files,
          meta: data.meta,
          clearError: true,
        ));
      },
    );
  }

  Future<void> extend(int id, int days) async {
    final result = await _repository.update(id, expiresInDays: days);
    if (isClosed) return;

    await result.fold(
      (failure) async {
        if (failure is PaymentRequiredFailure) {
          emit(state.copyWith(
            paymentRequired: failure,
            error: failure.message,
          ));
        } else {
          emit(state.copyWith(error: failure.message));
        }
      },
      (updatedFile) async {
        final updatedList = state.files.map((f) {
          return f.id == id ? updatedFile : f;
        }).toList();

        emit(state.copyWith(
          files: updatedList,
          clearError: true,
        ));
        // A reopened link counts towards the quota again.
        await _reloadMeta();
      },
    );
  }

  Future<void> delete(int id) async {
    final result = await _repository.delete(id);
    if (isClosed) return;

    await result.fold(
      (failure) async => emit(state.copyWith(error: failure.message)),
      (_) async {
        final updatedList = state.files.where((f) => f.id != id).toList();
        emit(state.copyWith(
          files: updatedList,
          clearError: true,
        ));
        // Reload meta so usedBytes and quota update
        await _reloadMeta();
      },
    );
  }

  Future<void> _reloadMeta() async {
    final result = await _repository.getFiles();
    if (isClosed) return;

    result.fold(
      (_) {},
      (data) {
        emit(state.copyWith(meta: data.meta));
      },
    );
  }

  Future<SharedFileModel?> openQr(int id) async {
    final result = await _repository.getFile(id);
    if (isClosed) return null;

    return result.fold(
      (failure) {
        emit(state.copyWith(error: failure.message));
        return null;
      },
      (fileWithQr) {
        emit(state.copyWith(selectedFile: fileWithQr));
        return fileWithQr;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';

part 'madrasati_import_state.dart';

/// «استيراد من مدرستي»: lists the Madrasati classes, reads the chosen
/// classes' names for review, then saves them to «فصولي».
class MadrasatiImportCubit extends Cubit<MadrasatiImportState> {
  static MadrasatiImportCubit get(BuildContext context) => BlocProvider.of(context);

  MadrasatiImportCubit(this._repo) : super(const MadrasatiImportState());

  final ClassesRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: MadrasatiImportStatus.loading));
    final result = await _repo.getMadrasatiClasses();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: MadrasatiImportStatus.failure, errorMessage: failure.message)),
      (classes) => emit(state.copyWith(
        status: MadrasatiImportStatus.success,
        rows: [for (final madrasatiClass in classes) MadrasatiImportRow(madrasatiClass)],
      )),
    );
  }

  /// Classes can be chosen only before reading.
  void toggle(int index) {
    if (state.isBusy || state.isRead) return;
    final row = state.rows[index];
    _setRow(index, row.copyWith(isChecked: !row.isChecked));
  }

  /// Reads the chosen classes one at a time, so Madrasati isn't asked for
  /// everything at once.
  Future<void> read() async {
    if (state.isBusy || state.rows.every((row) => !row.isChecked)) return;
    emit(state.copyWith(isBusy: true, clearError: true));
    String? error;
    for (var i = 0; i < state.rows.length; i++) {
      final row = state.rows[i];
      if (!row.isChecked) continue;
      _setRow(i, row.copyWith(status: MadrasatiRowStatus.reading));
      final result = await _repo.readMadrasatiClass(row.madrasatiClass.madrasatiId);
      if (isClosed) return;
      result.fold(
        (failure) {
          error = failure.message;
          _setRow(i, row.copyWith(status: MadrasatiRowStatus.failed));
        },
        (names) => _setRow(i, row.copyWith(status: MadrasatiRowStatus.read, students: names)),
      );
    }
    emit(state.copyWith(isBusy: false, isRead: true, errorMessage: error));
  }

  /// Saves each read class with names: replacing the «فصولي» class of the
  /// same name, or as a new one. Stops at the first failure; a retry skips
  /// the classes already saved.
  Future<void> save() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true, clearError: true));
    for (var i = 0; i < state.rows.length; i++) {
      final row = state.rows[i];
      if (!row.canSave) continue;
      final schoolClass = SchoolClassModel(
        name: row.madrasatiClass.name,
        grade: row.madrasatiClass.name,
        students: row.students,
      );
      final id = row.madrasatiClass.existingClassId;
      final result = id != null ? await _repo.updateClass(id, schoolClass) : await _repo.createClass(schoolClass);
      if (isClosed) return;
      final failure = result.fold((failure) => failure, (_) => null);
      if (failure != null) {
        emit(state.copyWith(isBusy: false, errorMessage: failure.message));
        return;
      }
      _setRow(i, row.copyWith(status: MadrasatiRowStatus.saved));
    }
    emit(state.copyWith(isBusy: false, isDone: true));
  }

  void _setRow(int index, MadrasatiImportRow row) => emit(state.copyWith(rows: [...state.rows]..[index] = row));
}

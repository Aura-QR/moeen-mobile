import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/ui_feedback.dart';
import 'package:moean/features/classes/data/models/school_class_model.dart';
import 'package:moean/features/classes/data/repositories/classes_repository.dart';

part 'classes_state.dart';

/// «فصولي»: the list of saved classes.
class ClassesCubit extends Cubit<ClassesState> {
  static ClassesCubit get(BuildContext context) => BlocProvider.of(context);

  ClassesCubit(this._repo) : super(const ClassesState());

  final ClassesRepository _repo;

  Future<void> load() async {
    if (state.classes.isEmpty) emit(state.copyWith(status: ClassesStatus.loading));
    final result = await _repo.getClasses();
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(status: ClassesStatus.failure, errorMessage: failure.message)),
      (classes) => emit(state.copyWith(status: ClassesStatus.success, classes: classes)),
    );
  }

  Future<void> delete(SchoolClassModel schoolClass) async {
    final id = schoolClass.id;
    if (id == null) return;
    emit(state.copyWith(busyId: id));
    final result = await _repo.deleteClass(id);
    if (isClosed) return;
    result.fold(
      (failure) => emit(state.copyWith(clearBusy: true, feedback: UiFeedback(failure.message))),
      (_) => emit(state.copyWith(
        clearBusy: true,
        classes: state.classes.where((c) => c.id != id).toList(),
        feedback: const UiFeedback('class_deleted', isError: false),
      )),
    );
  }
}

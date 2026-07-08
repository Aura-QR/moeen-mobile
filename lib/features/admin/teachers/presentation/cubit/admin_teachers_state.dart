import 'package:moean/core/models/admin_teacher_model.dart';

abstract class AdminTeachersState {}

class AdminTeachersInitial extends AdminTeachersState {}

class GetTeachersLoadingState extends AdminTeachersState {}

class GetTeachersSuccessState extends AdminTeachersState {
  final AdminTeacherPaginationModel paginationModel;

  GetTeachersSuccessState(this.paginationModel);
}

class GetTeachersErrorState extends AdminTeachersState {
  final String message;

  GetTeachersErrorState(this.message);
}

class AdminTeacherActionLoadingState extends AdminTeachersState {}

class AdminTeacherActionSuccessState extends AdminTeachersState {
  final String message;

  AdminTeacherActionSuccessState(this.message);
}

class AdminTeacherPasswordResetSuccessState extends AdminTeachersState {
  final String message;
  final String plainPassword;
  final int teacherId;

  AdminTeacherPasswordResetSuccessState(this.message, this.plainPassword, this.teacherId);
}

class AdminTeacherActionErrorState extends AdminTeachersState {
  final String message;

  AdminTeacherActionErrorState(this.message);
}

class AdminTeacherFilterChangedState extends AdminTeachersState {}

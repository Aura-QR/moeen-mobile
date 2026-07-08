import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/admin_teacher_model.dart';
import 'package:moean/features/admin/teachers/data/repositories/admin_teachers_repository.dart';
import 'package:moean/features/admin/teachers/presentation/cubit/admin_teachers_state.dart';

class AdminTeachersCubit extends Cubit<AdminTeachersState> {
  AdminTeachersCubit() : super(AdminTeachersInitial());

  static AdminTeachersCubit get(BuildContext context) => BlocProvider.of(context);

  AdminTeacherPaginationModel? paginationModel;
  List<AdminTeacherModel> teachersList = [];
  List<AdminTeacherSubscriptionModel> subscriptionsList = [];

  String? searchQuery;
  String? statusFilter;
  int currentPage = 1;
  bool isLastPage = false;
  int perPage = 20;

  TextEditingController searchController = TextEditingController();

  void getSubscriptions() async {
    final result = await AdminTeachersRepository.getSubscriptions();
    result.fold(
      (error) {}, // Handle error if needed
      (data) {
        subscriptionsList = data;
        emit(AdminTeacherFilterChangedState()); // Trigger a rebuild to update dialogs
      },
    );
  }

  void getTeachers({bool loadMore = false}) async {
    if (subscriptionsList.isEmpty) getSubscriptions();
    if (loadMore) {
      if (isLastPage) return;
      currentPage++;
    } else {
      currentPage = 1;
      teachersList.clear();
      emit(GetTeachersLoadingState());
    }

    final result = await AdminTeachersRepository.getTeachers(
      page: currentPage,
      perPage: perPage,
      search: searchQuery,
      status: statusFilter,
    );

    result.fold(
      (error) {
        emit(GetTeachersErrorState(error));
      },
      (data) {
        paginationModel = data;
        if (loadMore) {
          teachersList.addAll(data.data);
        } else {
          teachersList = List.from(data.data);
        }
        isLastPage = data.currentPage >= data.lastPage;
        emit(GetTeachersSuccessState(data));
      },
    );
  }

  void onSearchChanged(String value) {
    searchQuery = value.trim();
    if (searchQuery!.isEmpty) {
      searchQuery = null;
    }
    emit(AdminTeacherFilterChangedState());
    getTeachers();
  }

  void onStatusFilterChanged(String? value) {
    statusFilter = value;
    emit(AdminTeacherFilterChangedState());
    getTeachers();
  }

  Future<void> addTeacher({
    required String name,
    required String email,
    required String phone,
    required String password,
    required int subscriptionId,
  }) async {
    emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.createTeacher(
      name: name,
      email: email,
      phone: phone,
      password: password,
      subscriptionId: subscriptionId,
    );

    result.fold(
      (error) {
        emit(AdminTeacherActionErrorState(error));
      },
      (teacher) {
        emit(AdminTeacherActionSuccessState('تم إضافة المعلم بنجاح'));
        getTeachers();
      },
    );
  }

  Future<void> updateTeacher({
    required int id,
    String? name,
    String? email,
    String? phone,
    bool? active,
    int? subscriptionId,
    String? subscriptionEndsAt,
    String? password,
  }) async {
    emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.updateTeacher(
      id: id,
      name: name,
      email: email,
      phone: phone,
      active: active,
      subscriptionId: subscriptionId,
      subscriptionEndsAt: subscriptionEndsAt,
      password: password,
    );

    result.fold(
      (error) {
        emit(AdminTeacherActionErrorState(error));
      },
      (teacher) {
        emit(AdminTeacherActionSuccessState('تم تحديث بيانات المعلم بنجاح'));
        getTeachers();
      },
    );
  }

  Future<void> renewSubscription({
    required int id,
    int? subscriptionId,
    int? months,
  }) async {
    emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.renewSubscription(
      id: id,
      subscriptionId: subscriptionId,
      months: months,
    );

    result.fold(
      (error) {
        emit(AdminTeacherActionErrorState(error));
      },
      (teacher) {
        emit(AdminTeacherActionSuccessState('تم تجديد الاشتراك بنجاح'));
        getTeachers();
      },
    );
  }

  Future<void> removeSubscription({required int id}) async {
    emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.removeSubscription(id: id);

    result.fold(
      (error) {
        emit(AdminTeacherActionErrorState(error));
      },
      (teacher) {
        emit(AdminTeacherActionSuccessState('تم إلغاء الاشتراك بنجاح'));
        getTeachers();
      },
    );
  }

  Future<void> resetPassword({required int id}) async {
    emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.resetPassword(id: id);

    result.fold(
      (error) {
        emit(AdminTeacherActionErrorState(error));
      },
      (password) {
        emit(AdminTeacherPasswordResetSuccessState('تم إعادة تعيين كلمة المرور بنجاح', password, id));
      },
    );
  }

  Future<void> deleteTeacher({required int id}) async {
    emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.deleteTeacher(id: id);

    result.fold(
      (error) {
        emit(AdminTeacherActionErrorState(error));
      },
      (success) {
        emit(AdminTeacherActionSuccessState('تم حذف المعلم بنجاح'));
        getTeachers();
      },
    );
  }

  Future<void> toggleTeacherStatus({required AdminTeacherModel teacher}) async {
    await updateTeacher(id: teacher.id, active: !teacher.active);
  }
}

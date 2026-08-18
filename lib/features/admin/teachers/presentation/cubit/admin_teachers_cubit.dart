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
    if (isClosed) return;
    result.fold(
      (error) {}, // Handle error if needed
      (data) {
        subscriptionsList = data;
        if (!isClosed) emit(AdminTeacherFilterChangedState()); // Trigger a rebuild to update dialogs
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
      if (!isClosed) emit(GetTeachersLoadingState());
    }

    final result = await AdminTeachersRepository.getTeachers(
      page: currentPage,
      perPage: perPage,
      search: searchQuery,
      status: statusFilter,
    );
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(GetTeachersErrorState(error));
      },
      (data) {
        paginationModel = data;
        if (loadMore) {
          teachersList.addAll(data.data);
        } else {
          teachersList = List.from(data.data);
        }
        isLastPage = data.currentPage >= data.lastPage;
        if (!isClosed) emit(GetTeachersSuccessState(data));
      },
    );
  }

  void onSearchChanged(String value) {
    searchQuery = value.trim();
    if (searchQuery!.isEmpty) {
      searchQuery = null;
    }
    if (!isClosed) emit(AdminTeacherFilterChangedState());
    getTeachers();
  }

  void onStatusFilterChanged(String? value) {
    statusFilter = value;
    if (!isClosed) emit(AdminTeacherFilterChangedState());
    getTeachers();
  }

  Future<void> addTeacher({
    required String name,
    required String email,
    required String phone,
    required String password,
    required int subscriptionId,
  }) async {
    if (!isClosed) emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.createTeacher(
      name: name,
      email: email,
      phone: phone,
      password: password,
      subscriptionId: subscriptionId,
    );
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AdminTeacherActionErrorState(error));
      },
      (teacher) {
        if (!isClosed) emit(AdminTeacherActionSuccessState('تم إضافة المعلم بنجاح'));
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
    if (!isClosed) emit(AdminTeacherActionLoadingState());
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
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AdminTeacherActionErrorState(error));
      },
      (teacher) {
        if (!isClosed) emit(AdminTeacherActionSuccessState('تم تحديث بيانات المعلم بنجاح'));
        getTeachers();
      },
    );
  }

  Future<void> renewSubscription({
    required int id,
    int? subscriptionId,
    int? months,
  }) async {
    if (!isClosed) emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.renewSubscription(
      id: id,
      subscriptionId: subscriptionId,
      months: months,
    );
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AdminTeacherActionErrorState(error));
      },
      (teacher) {
        if (!isClosed) emit(AdminTeacherActionSuccessState('تم تجديد الاشتراك بنجاح'));
        getTeachers();
      },
    );
  }

  Future<void> removeSubscription({required int id}) async {
    if (!isClosed) emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.removeSubscription(id: id);
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AdminTeacherActionErrorState(error));
      },
      (teacher) {
        if (!isClosed) emit(AdminTeacherActionSuccessState('تم إلغاء الاشتراك بنجاح'));
        getTeachers();
      },
    );
  }

  Future<void> resetPassword({required int id}) async {
    if (!isClosed) emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.resetPassword(id: id);
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AdminTeacherActionErrorState(error));
      },
      (password) {
        if (!isClosed) emit(AdminTeacherPasswordResetSuccessState('تم إعادة تعيين كلمة المرور بنجاح', password, id));
      },
    );
  }

  Future<void> deleteTeacher({required int id}) async {
    if (!isClosed) emit(AdminTeacherActionLoadingState());
    final result = await AdminTeachersRepository.deleteTeacher(id: id);
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AdminTeacherActionErrorState(error));
      },
      (success) {
        if (!isClosed) emit(AdminTeacherActionSuccessState('تم حذف المعلم بنجاح'));
        getTeachers();
      },
    );
  }

  Future<void> toggleTeacherStatus({required AdminTeacherModel teacher}) async {
    await updateTeacher(id: teacher.id, active: !teacher.active);
  }
}

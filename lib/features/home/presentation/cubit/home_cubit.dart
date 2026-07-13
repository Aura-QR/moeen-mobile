import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/network/local/cache_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  static HomeCubit get(BuildContext context) => BlocProvider.of(context);

  int selectedCategoryIndex = 0;
  final TextEditingController searchController = TextEditingController();

  bool isAdmin = false;
  bool isLoadingRole = true;

  void onSearchChanged(String query) {
    emit(HomeSearchChanged(query: query));
  }

  void onCategorySelected(int index) {
    selectedCategoryIndex = index;
    emit(HomeCategoryChanged(selectedIndex: index));
  }

  Future<void> checkRole() async {
    if (token != null && token!.isNotEmpty) {
      final cachedIsAdmin = CacheHelper.getData(key: 'isAdmin');
      final cachedToken = CacheHelper.getData(key: 'admin_token');
      if (cachedIsAdmin != null && cachedIsAdmin is bool && cachedToken == token) {
        isAdmin = cachedIsAdmin;
        isLoadingRole = false;
        emit(HomeRoleChecked(isAdmin: isAdmin));
        return;
      }

      final result = await ApiService.getProfile();
      result.fold(
        (error) {
          isLoadingRole = false;
          emit(HomeRoleChecked(isAdmin: isAdmin)); // emit with current/default
        },
        (profile) {
          final admin = profile.role == 'admin' || profile.user.email == 'admin@moeen.sa';
          CacheHelper.saveData(key: 'isAdmin', value: admin);
          CacheHelper.saveData(key: 'admin_token', value: token);
          isAdmin = admin;
          isLoadingRole = false;
          emit(HomeRoleChecked(isAdmin: isAdmin));
        },
      );
    } else {
      isLoadingRole = false;
      emit(HomeRoleChecked(isAdmin: false));
    }
  }

  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}

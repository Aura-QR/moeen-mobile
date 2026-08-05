import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/profile/presentation/cubit/profile_state.dart';
import 'package:moean/core/models/profile_model.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/services/madrasati_session_service.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitialState());

  static ProfileCubit get(BuildContext context) => BlocProvider.of(context);

  ProfileModel? profileModel;

  Future<void> fetchProfile() async {
    emit(ProfileLoadingState());
    final result = await ApiService.getProfile();
    result.fold(
      (error) => emit(ProfileErrorState(message: error)),
      (profile) {
        profileModel = profile;
        emit(ProfileLoadedState(profile: profile));
      },
    );
  }

  Future<void> logout() async {
    emit(ProfileLogoutLoadingState());

    try {
      // 1. مسح التوكن فوراً من الذاكرة والـ Storage
      final secureStorage = sl<SecureStorageHelper>();
      await secureStorage.deleteToken();
      token = null;

      // 2. إرسال حالة النجاح فوراً لكي تلتقطها الشاشة قبل أي Rebuild
      emit(ProfileLogoutSuccessState());

      // 3. تصفير جلسة مدرستي وطلب السيرفر في الخلفية
      sl<MadrasatiSessionService>().reset();
      ApiService.logout(); 

    } catch (e) {
      debugPrint('Logout error: $e');
      // في حال حدوث خطأ، نضمن أيضاً إرسال النجاح لتسجيل الخروج محلياً
      token = null;
      emit(ProfileLogoutSuccessState());
    }
  }

  void clearData() {
    profileModel = null;
  }
}

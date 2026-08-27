import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/profile/presentation/cubit/profile_state.dart';
import 'package:moean/core/models/profile_model.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/services/madrasati_session_service.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_cubit.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitialState());

  static ProfileCubit get(BuildContext context) => BlocProvider.of(context);

  ProfileModel? profileModel;
  bool _isLoading = false;

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    if (token == null || token!.isEmpty) return;
    if (_isLoading) return;

    if (!forceRefresh && profileModel != null) {
      if (!isClosed) emit(ProfileLoadedState(profile: profileModel!));
      return;
    }

    _isLoading = true;
    if (!isClosed) {
      if (forceRefresh) {
        profileModel = null;
        emit(ProfileLoadingState());
      } else if (profileModel == null) {
        emit(ProfileLoadingState());
      }
    }

    final result = await ApiService.getProfile();
    _isLoading = false;
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(ProfileErrorState(message: error));
      },
      (profile) {
        profileModel = profile;
        if (!isClosed) emit(ProfileLoadedState(profile: profile));
      },
    );
  }

  Future<void> logout() async {
    if (!isClosed) emit(ProfileLogoutLoadingState());

    try {
      // 1. مسح التوكن فوراً من الذاكرة والـ Storage
      final secureStorage = sl<SecureStorageHelper>();
      await secureStorage.deleteToken();
      token = null;
      clearData();
      sl<SubscriptionCubit>().clearData();

      // 2. إرسال حالة النجاح فوراً لكي تلتقطها الشاشة قبل أي Rebuild
      if (!isClosed) emit(ProfileLogoutSuccessState());

      // 3. تصفير جلسة مدرستي وطلب السيرفر في الخلفية
      sl<MadrasatiSessionService>().reset();
      ApiService.logout(); 

    } catch (e) {
      debugPrint('Logout error: $e');
      // في حال حدوث خطأ، نضمن أيضاً إرسال النجاح لتسجيل الخروج محلياً
      token = null;
      clearData();
      sl<SubscriptionCubit>().clearData();
      if (!isClosed) emit(ProfileLogoutSuccessState());
    }
  }

  void clearData() {
    profileModel = null;
    if (!isClosed) emit(ProfileInitialState());
  }
}

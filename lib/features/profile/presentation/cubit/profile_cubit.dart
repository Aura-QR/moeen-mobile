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

    final result = await ApiService.logout();

    result.fold(
      (error) {
        _clearLocalAuthData();
        emit(ProfileLogoutSuccessState()); // Even on error, we clear local session
      },
      (success) {
        _clearLocalAuthData();
        emit(ProfileLogoutSuccessState());
      },
    );
  }

  Future<void> _clearLocalAuthData() async {
    final secureStorage = sl<SecureStorageHelper>();
    await secureStorage.deleteToken();
    token = null;
    sl<MadrasatiSessionService>().reset();
  }
}

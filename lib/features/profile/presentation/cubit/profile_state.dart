import 'package:moean/core/models/profile_model.dart';

abstract class ProfileState {}

class ProfileInitialState extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileLoadedState extends ProfileState {
  final ProfileModel profile;
  ProfileLoadedState({required this.profile});
}

class ProfileErrorState extends ProfileState {
  final String message;
  ProfileErrorState({required this.message});
}

class ProfileLogoutLoadingState extends ProfileState {}

class ProfileLogoutSuccessState extends ProfileState {}

class ProfileLogoutErrorState extends ProfileState {
  final String message;
  ProfileLogoutErrorState({required this.message});
}

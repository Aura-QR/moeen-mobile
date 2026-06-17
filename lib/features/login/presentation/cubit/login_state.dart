abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  final bool madrasatiConnected;
  LoginSuccessState({required this.madrasatiConnected});
}

class LoginErrorState extends LoginState {
  final String message;
  LoginErrorState({required this.message});
}

class LoginPasswordVisibilityChangedState extends LoginState {}

class LoginRememberMeChangedState extends LoginState {}

class LoginUpdateUIState extends LoginState {}

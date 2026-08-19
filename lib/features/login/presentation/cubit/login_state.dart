abstract class LoginState {}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  final bool madrasatiConnected;
  final String userEmail;
  LoginSuccessState({required this.madrasatiConnected, required this.userEmail});
}

class LoginErrorState extends LoginState {
  final String message;
  LoginErrorState({required this.message});
}

class LoginAccountSuspendedState extends LoginState {
  final String? email;
  final String? password;
  final String? message;
  final String? userName;

  LoginAccountSuspendedState({
    this.email,
    this.password,
    this.message,
    this.userName,
  });
}

class LoginPasswordVisibilityChangedState extends LoginState {}

class LoginRememberMeChangedState extends LoginState {}

class LoginUpdateUIState extends LoginState {}

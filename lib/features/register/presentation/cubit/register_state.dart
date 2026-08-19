abstract class RegisterState {}

class RegisterInitialState extends RegisterState {}

class RegisterLoadingState extends RegisterState {}

class RegisterSuccessState extends RegisterState {
  final String email;
  RegisterSuccessState({required this.email});
}

class RegisterErrorState extends RegisterState {
  final String message;
  RegisterErrorState({required this.message});
}

class RegisterPasswordVisibilityChangedState extends RegisterState {}

class RegisterConfirmPasswordVisibilityChangedState extends RegisterState {}

class RegisterAccountTypeChangedState extends RegisterState {}

class RegisterTermsChangedState extends RegisterState {}

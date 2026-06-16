abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthSendOtpLoadingState extends AuthState {}

class AuthSendOtpSuccessState extends AuthState {}

class AuthSendOtpErrorState extends AuthState {
  final String message;
  AuthSendOtpErrorState({required this.message});
}

class AuthVerifyOtpLoadingState extends AuthState {}

class AuthVerifyOtpSuccessState extends AuthState {}

class AuthVerifyOtpErrorState extends AuthState {
  final String message;
  AuthVerifyOtpErrorState({required this.message});
}

class AuthShowPasswordState extends AuthState {}

class AuthLoginLoadingState extends AuthState {}

class AuthLoginSuccessState extends AuthState {}

class AuthLoginErrorState extends AuthState {
  final String message;

  AuthLoginErrorState({required this.message});
}

class AuthUserLoadedFromCacheState extends AuthState {}

class AuthRegisterLoadingState extends AuthState {}

class AuthRegisterSuccessState extends AuthState {}

class AuthRegisterErrorState extends AuthState {
  final String message;

  AuthRegisterErrorState({required this.message});
}

class AuthUpdateUIState extends AuthState {}

class AuthUserUpdatedState extends AuthState {}

// ─── Forgot Password Flow ───────────────────────────────────────────────────

class AuthForgotPasswordLoadingState extends AuthState {}

class AuthForgotPasswordSuccessState extends AuthState {}

class AuthForgotPasswordErrorState extends AuthState {
  final String message;
  AuthForgotPasswordErrorState({required this.message});
}

class AuthResetPasswordLoadingState extends AuthState {}

class AuthResetPasswordSuccessState extends AuthState {}

class AuthResetPasswordErrorState extends AuthState {
  final String message;
  AuthResetPasswordErrorState({required this.message});
}

// ─── Change Password & Logout ────────────────────────────────────────────────
class AuthChangePasswordLoadingState extends AuthState {}

class AuthChangePasswordSuccessState extends AuthState {}

class AuthChangePasswordErrorState extends AuthState {
  final String message;
  AuthChangePasswordErrorState({required this.message});
}

class AuthLogoutLoadingState extends AuthState {}

class AuthLogoutSuccessState extends AuthState {}

class AuthLogoutErrorState extends AuthState {
  final String message;
  AuthLogoutErrorState({required this.message});
}

class AuthLogoutAllLoadingState extends AuthState {}

class AuthLogoutAllSuccessState extends AuthState {}

class AuthLogoutAllErrorState extends AuthState {
  final String message;
  AuthLogoutAllErrorState({required this.message});
}

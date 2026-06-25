import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/login/presentation/cubit/login_state.dart';
import 'package:moean/main.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/models/login_request.dart';
import 'package:moean/core/models/madrasati_session_data.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/services/madrasati_session_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/di/injections.dart';

LoginCubit get loginCubit => LoginCubit.get(navigatorKey.currentContext!);

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitialState());

  static LoginCubit get(BuildContext context) => BlocProvider.of(context);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool rememberMe = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(LoginPasswordVisibilityChangedState());
  }

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    emit(LoginRememberMeChangedState());
  }

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    emit(LoginLoadingState());

    final request = LoginRequest(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    final result = await ApiService.loginUser(request);

    result.fold(
      (error) {
        emit(LoginErrorState(message: error));
      },
      (response) async {
        // Save token securely (replaces CacheHelper for sensitive data)
        await sl<SecureStorageHelper>().saveToken(response.token);
        token = response.token;

        // If already connected to Madrasati, persist school_id locally
        // so HeadlessRefresh can use it when session expires
        if (response.madrasatiConnected &&
            response.madrasatiSchoolId != null &&
            response.madrasatiSchoolId!.isNotEmpty) {
          await sl<SecureStorageHelper>().saveMadrasatiSession(
            MadrasatiSessionData(
              sessionCookie: '', // cookies managed by WebView internally
              schoolId: response.madrasatiSchoolId!,
              expiresAt: null,
            ),
          );
          sl<MadrasatiSessionService>().notifySessionActive();
        }

        emit(LoginSuccessState(madrasatiConnected: response.madrasatiConnected));
      },
    );
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}

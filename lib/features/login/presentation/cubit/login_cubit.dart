import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/login/presentation/cubit/login_state.dart';
import 'package:moean/main.dart';

LoginCubit get loginCubit =>
    LoginCubit.get(navigatorKey.currentContext!);

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

  void login() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    emit(LoginLoadingState());

    Future.delayed(const Duration(seconds: 2), () {
      emit(LoginSuccessState());
    });
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}

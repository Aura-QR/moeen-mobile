import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/register/presentation/cubit/register_state.dart';

enum AccountType { teacher, supervisor }

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitialState());

  static RegisterCubit get(BuildContext context) => BlocProvider.of(context);

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeToTerms = false;
  AccountType selectedAccountType = AccountType.teacher;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(RegisterPasswordVisibilityChangedState());
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    emit(RegisterConfirmPasswordVisibilityChangedState());
  }

  void toggleTerms() {
    agreeToTerms = !agreeToTerms;
    emit(RegisterTermsChangedState());
  }

  void setAccountType(AccountType type) {
    selectedAccountType = type;
    emit(RegisterAccountTypeChangedState());
  }

  void register() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!agreeToTerms) return;
    emit(RegisterLoadingState());

    Future.delayed(const Duration(seconds: 2), () {
      emit(RegisterSuccessState());
    });
  }

  @override
  Future<void> close() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}

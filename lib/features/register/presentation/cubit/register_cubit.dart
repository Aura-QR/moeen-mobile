import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/register/presentation/cubit/register_state.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/models/register_request.dart';
import 'package:moean/core/network/local/cache_helper.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_cubit.dart';

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

  Future<void> register() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      if (!isClosed) emit(RegisterInitialState());
      return;
    }
    if (!agreeToTerms) {
      if (!isClosed) emit(RegisterErrorState(message: 'يجب الموافقة على الشروط والأحكام'));
      return;
    }
    if (!isClosed) emit(RegisterLoadingState());

    try {
      final referralCode = CacheHelper.getData(key: 'referral_code')?.toString();

      final request = RegisterRequest(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
        referralCode: referralCode,
      );

      final result = await ApiService.registerUser(request);
      if (isClosed) return;

      result.fold(
        (error) {
          if (!isClosed) emit(RegisterErrorState(message: error));
          debugPrint('Register Error: $error');
        },
        (response) async {
          await CacheHelper.saveData(key: 'auth_token', value: response.token);
          await sl<SecureStorageHelper>().saveToken(response.token);
          
          // Clear the referral code after successful registration
          if (referralCode != null && referralCode.isNotEmpty) {
            await CacheHelper.removeData(key: 'referral_code');
            debugPrint('Cleared locally stored referral code after successful registration.');
          }

          token = response.token;
          sl<SubscriptionCubit>().fetchCurrentSubscription();
          if (!isClosed) emit(RegisterSuccessState(email: response.user.email));
          debugPrint('Register Success: $response');
        },
      );
    } catch (e, stack) {
      debugPrint('Register Exception: $e\n$stack');
      if (!isClosed) emit(RegisterErrorState(message: e.toString()));
    }
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

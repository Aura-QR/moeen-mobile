// import 'dart:async';
// import 'dart:convert';

// import 'package:moean/core/network/local/cache_helper.dart';
// import 'package:moean/core/network/remote/api_endpoints.dart';
// import 'package:moean/core/network/remote/dio_helper.dart';
// import 'package:moean/core/utils/constants/constants.dart';
// import 'package:moean/core/utils/cubit/auth/auth_state.dart';
// import 'package:moean/core/models/user_model.dart';
// import 'package:moean/core/models/register_request.dart';
// import 'package:moean/core/network/remote/api_service.dart';
// import 'package:moean/core/helpers/fcm_helper.dart';
// import 'package:moean/main.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:moean/core/di/injections.dart';
// import 'package:moean/features/profile/presentation/cubit/profile_cubit.dart';
// import 'package:moean/features/notifications/logic/cubit/notification_cubit.dart';


// AuthCubit get authCubit => AuthCubit.get(navigatorKey.currentContext!);

// class AuthCubit extends Cubit<AuthState> {
//   AuthCubit() : super(AuthInitialState());
//   int registerCallCount = 0;
//   int otpCount = 0;

//   static AuthCubit get(BuildContext context) => BlocProvider.of(context);

//   // Login Controllers
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   // Register Controllers
//   final TextEditingController fullNameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController nationalIdController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();
//   final TextEditingController nationalIdRegisterController =
//       TextEditingController();
//   final TextEditingController dateController = TextEditingController();

//   // Forgot Password Controllers
//   final TextEditingController forgotLoginController = TextEditingController();
//   final TextEditingController resetOtpController = TextEditingController();
//   final TextEditingController newPasswordController = TextEditingController();
//   final TextEditingController confirmNewPasswordController =
//       TextEditingController();

//   bool isShowNewPassword = false;
//   bool isShowConfirmNewPassword = false;
//   bool isShowCurrentPassword = false;
//   bool isShowChangePassword = false;
//   bool isShowConfirmChangePassword = false;

//   final TextEditingController currentPasswordController = TextEditingController();
//   final TextEditingController changePasswordController = TextEditingController();
//   final TextEditingController confirmChangePasswordController = TextEditingController();

//   bool isShowPassword = false;
//   bool isShowConfirmPassword = false;
//   int selectedGender = 0; // 0 for male, 1 for female
//   bool isAgreedToTerms = false;

//   // Resend OTP Timer
//   Timer? _resendTimer;
//   int resendCountdown = 0;

//   void startResendTimer() {
//     resendCountdown = 180; // 3 minutes
//     _resendTimer?.cancel();
//     _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (resendCountdown > 0) {
//         resendCountdown--;
//         notifyUI();
//       } else {
//         _resendTimer?.cancel();
//         notifyUI();
//       }
//     });
//   }

//   @override
//   Future<void> close() {
//     _resendTimer?.cancel();
//     return super.close();
//   }

//   void changePasswordVisibility() {
//     isShowPassword = !isShowPassword;
//     emit(AuthShowPasswordState());
//   }

//   void changeConfirmPasswordVisibility() {
//     isShowConfirmPassword = !isShowConfirmPassword;
//     emit(AuthShowPasswordState());
//   }

//   void notifyUI() => emit(AuthUpdateUIState());

//   void changeGender(int value) {
//     selectedGender = value;
//     emit(AuthUpdateUIState());
//   }

//   void toggleTermsAgreement(bool value) {
//     isAgreedToTerms = value;
//     emit(AuthUpdateUIState());
//   }

//   Future<void> selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       final formattedDate =
//           "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
//       dateController.text = formattedDate;
//       emit(AuthUpdateUIState());
//     }
//   }

//   UserModel? userModel;
//   int? pendingUserId;

//   Future<void> login() async {
//     emit(AuthLoginLoadingState());
    
//     final String loginValue = emailController.text.trim();
//     final String passwordValue = passwordController.text.trim();
    
//     debugPrint('🔍 Debug Login - Login: $loginValue');
//     debugPrint('🔍 Debug Login - Password: $passwordValue');

//     final result = await DioHelper.postData(
//       url: loginApi,
//       data: {
//         'login': loginValue,
//         'password': passwordValue,
//       },
//     );
//     result.fold(
//       (failure) {
//         debugPrint('❌ Login Error: $failure');
//         emit(AuthLoginErrorState(message: failure.toString()));
//       },
//       (response) {
//         final responseData = response.data as Map<String, dynamic>?;

//         if (responseData == null) {
//           emit(AuthLoginErrorState(message: 'Invalid login response'));
//           return;
//         }

//         final bool isSuccess =
//             (responseData['success'] == true ||
//             (responseData['data'] != null &&
//                 (responseData['data']['token'] != null ||
//                     responseData['data']['access_token'] != null)) ||
//             responseData['token'] != null ||
//             responseData['access_token'] != null ||
//             (responseData['message']?.toString().toLowerCase().contains(
//                   'success',
//                 ) ??
//                 false));

//         if (isSuccess) {
//           final bool hasToken = _storeTokenFromResponse(responseData);
//           if (!hasToken) {
//             debugPrint('❌ Login response has no token: $responseData');
//             emit(
//               AuthLoginErrorState(
//                 message: 'Login succeeded but token is missing. Please retry.',
//               ),
//             );
//             return;
//           }

//           _handleLoginSuccess(responseData);
//           debugPrint('✅ Login Success Header: ${responseData['message']}');
//           emit(AuthLoginSuccessState());
//         } else {
//           debugPrint('❌ Login Failed Header: ${responseData['message']}');
//           emit(
//             AuthLoginErrorState(
//               message: responseData['message'] ?? 'Login failed',
//             ),
//           );
//         }
//       },
//     );
//   }

//   Future<void> register() async {
//      registerCallCount++;

//   debugPrint(
//     '🚀 Register button pressed: $registerCallCount time(s)'
//   );

//     emit(AuthRegisterLoadingState());
//     final request = RegisterRequest(
//       name: fullNameController.text.trim(),
//       phone: phoneController.text.trim(),
//       email: emailController.text.trim(),
//       password: passwordController.text,
//       passwordConfirmation: confirmPasswordController.text,
//       nationalId: nationalIdController.text.trim(),
//       dateOfBirth: dateController.text.trim(),
//       gender: selectedGender == 0 ? 'male' : 'female',
//     );
//     debugPrint('🚀 Registration Request: ${request.toJson()}');
// debugPrint('📡 Calling Register API...');
//     try {
//       final response = await ApiService.registerUser(request);

//       final bool isSuccess =
//           response.success ||
//           (response.message?.toLowerCase().contains('success') ?? false);

//       if (isSuccess) {
//         debugPrint('✅ Register Success');
//         pendingUserId = response.userId;
//         startResendTimer();
//         emit(AuthRegisterSuccessState());
//       } else {
//         debugPrint('❌ Register Failed Header: ${response.message}');
//         emit(
//           AuthRegisterErrorState(
//             message: response.message ?? 'Registration failed',
//           ),
//         );
//       }
//     } catch (e) {
//       emit(AuthRegisterErrorState(message: e.toString()));
//     }
//   }

//   void _handleLoginSuccess(Map<String, dynamic> responseBody) {
//     final innerData = responseBody['data'] as Map<String, dynamic>?;

//     // Ensure token is extracted and stored from any supported response shape.
//     _storeTokenFromResponse(responseBody);

//     if (innerData != null) {
//       if (innerData['user'] != null) {
//         userModel = UserModel.fromJson(
//           innerData['user'] as Map<String, dynamic>,
//         );
//         CacheHelper.saveData(
//           key: 'cached_user',
//           value: jsonEncode(userModel!.toJson()),
//         );
//       }
//     }
//     _clearControllers();
//     fetchBootstrapData();
//     fetchFreshProfile();
//   }

//   bool _storeTokenFromResponse(Map<String, dynamic> responseData) {
//     final innerData = responseData['data'] as Map<String, dynamic>?;
//     final extractedToken =
//         (innerData != null
//                 ? (innerData['token'] ?? innerData['access_token'])
//                 : (responseData['token'] ?? responseData['access_token']))
//             as String?;

//     if (extractedToken == null || extractedToken.isEmpty) {
//       return false;
//     }

//     token = extractedToken;
//     CacheHelper.saveData(key: 'auth_token', value: token);
//     ApiService.setToken(extractedToken);
//     FcmHelper.getAndSendTokenToServer();
//     return true;
//   }

//   Future<bool> _autoLoginAfterOtpVerification() async {
//     final loginValue = phoneController.text.trim();
//     final passwordValue = passwordController.text.trim();

//     if (loginValue.isEmpty || passwordValue.isEmpty) {
//       return false;
//     }

//     final loginResult = await DioHelper.postData(
//       url: loginApi,
//       data: {
//         'login': loginValue,
//         'password': passwordValue,
//       },
//     );

//     bool loggedIn = false;
//     loginResult.fold(
//       (failure) {
//         debugPrint('❌ Auto-login after OTP failed: $failure');
//       },
//       (response) {
//         final loginResponseData = response.data as Map<String, dynamic>?;
//         if (loginResponseData != null) {
//           loggedIn = _storeTokenFromResponse(loginResponseData);
//           if (loggedIn && loginResponseData['data'] is Map<String, dynamic>) {
//             _handleLoginSuccess(loginResponseData);
//           }
//         }
//       },
//     );

//     return loggedIn;
//   }

//   void loadCachedUser() {
//     final cached = CacheHelper.getData(key: 'cached_user');

//     if (cached != null) {
//       if (cached is String) {
//         userModel = UserModel.fromJson(jsonDecode(cached));
//       } else if (cached is Map<String, dynamic>) {
//         userModel = UserModel.fromJson(cached);
//       }

//       emit(AuthUserLoadedFromCacheState());
//       fetchBootstrapData();
//       fetchFreshProfile();
//     }
//   }

//   Future<void> fetchFreshProfile() async {
//     final result = await DioHelper.getData(url: patientProfileApi);
//     result.fold(
//       (error) => debugPrint('Error fetching fresh profile in AuthCubit: $error'),
//       (response) {
//         try {
//           final data = response.data['data'];
//           if (data != null) {
//             final avatar = data['profile']?['avatar'] ?? data['patient']?['avatar'];
//             final name = data['patient']?['name'] ?? data['user']?['name'];
            
//             if (userModel != null) {
//               updateUser(userModel!.copyWith(
//                 avatar: (avatar != null && avatar.toString().trim().isNotEmpty) ? avatar : userModel!.avatar,
//                 name: (name != null && name.toString().trim().isNotEmpty) ? name : userModel!.name,
//               ));
//             }
//           }
//         } catch (e) {
//           debugPrint('Error parsing fresh profile: $e');
//         }
//       },
//     );
//   }

//   Future<void> fetchBootstrapData() async {
//     final result = await DioHelper.getData(url: bootstrapApi);
//     result.fold(
//       (failure) {
//         debugPrint('❌ Bootstrap API Error: $failure');
//       },
//       (response) {
//         final responseData = response.data;
//         debugPrint('✅ Bootstrap API Success');
//         if (responseData != null) {
//           CacheHelper.saveData(
//             key: 'bootstrap_data',
//             value: jsonEncode(responseData),
//           );
//         }
//       },
//     );
//   }

//   void _clearControllers() {
//     emailController.clear();
//     passwordController.clear();
//     fullNameController.clear();
//     phoneController.clear();
//     nationalIdController.clear();
//     confirmPasswordController.clear();
//     dateController.clear();
//     otpController.clear();
//     forgotLoginController.clear();
//     resetOtpController.clear();
//     newPasswordController.clear();
//     confirmNewPasswordController.clear();
//     currentPasswordController.clear();
//     changePasswordController.clear();
//     confirmChangePasswordController.clear();
//     isAgreedToTerms = false;
//   }

//   Future<void> sendOtp() async {
//      otpCount++;
//   debugPrint('📩 Send OTP called: $otpCount');
//     emit(AuthSendOtpLoadingState());
//     final result = await DioHelper.postData(
//       url: sendOtpApi,
//       data: {
//         'login': phoneController.text.trim().isEmpty 
//             ? emailController.text.trim() 
//             : phoneController.text.trim(),
//       },
//     );
//     result.fold(
//       (failure) {
//         debugPrint('❌ Send OTP Error: $failure');
//         emit(AuthSendOtpErrorState(message: failure.toString()));
//       },
//       (response) {
//         final responseData = response.data as Map<String, dynamic>?;
//         final bool isSuccess =
//             responseData != null &&
//             (responseData['success'] == true ||
//                 (responseData['message']?.toString().toLowerCase().contains(
//                       'success',
//                     ) ??
//                     false));

//         if (isSuccess) {
//           debugPrint('✅ Send OTP Success header: ${response.data}');
//           startResendTimer();
//           emit(AuthSendOtpSuccessState());
//         } else {
//           debugPrint('❌ Send OTP Error header: ${response.data}');
//           emit(
//             AuthSendOtpErrorState(
//               message: responseData?['message'] ?? 'Failed to send OTP',
//             ),
//           );
//         }
//       },
//     );
//   }

//   Future<void> resendOtp() async {
//     final userId = pendingUserId ?? userModel?.id;
//     if (userId == null) {
//       debugPrint('⚠️ No user_id found, falling back to sendOtp');
//       return sendOtp();
//     }

//     emit(AuthSendOtpLoadingState());
//     final result = await DioHelper.postData(
//       url: resendOtpApi,
//       data: {
//         'user_id': userId,
//       },
//     );
//     result.fold(
//       (failure) {
//         debugPrint('❌ Resend OTP Error: $failure');
//         emit(AuthSendOtpErrorState(message: failure.toString()));
//       },
//       (response) {
//         final responseData = response.data as Map<String, dynamic>?;
//         final bool isSuccess =
//             responseData != null &&
//             (responseData['success'] == true ||
//                 (responseData['message']?.toString().toLowerCase().contains(
//                       'success',
//                     ) ??
//                     false));

//         if (isSuccess) {
//           debugPrint('✅ Resend OTP Success');
//           startResendTimer();
//           emit(AuthSendOtpSuccessState());
//         } else {
//           emit(
//             AuthSendOtpErrorState(
//               message: responseData?['message'] ?? 'Failed to resend OTP',
//             ),
//           );
//         }
//       },
//     );
//   }

//   Future<void> verifyOtp(String otp) async {
//     emit(AuthVerifyOtpLoadingState());
//     final result = await DioHelper.postData(
//       url: verifyOtpApi,
//       data: {
//         'login': phoneController.text.trim().isEmpty 
//             ? emailController.text.trim() 
//             : phoneController.text.trim(),
//         'otp': otp,
//       },
//     );
//     result.fold(
//       (failure) {
//         debugPrint('❌ Verify OTP Error: $failure');
//         emit(AuthVerifyOtpErrorState(message: failure.toString()));
//       },
//       (response) async {
//         final responseData = response.data as Map<String, dynamic>?;
//         debugPrint('==== OTP RESPONSE DATA: $responseData ====');
//         final bool isSuccess =
//             responseData != null &&
//             (responseData['success'] == true ||
//                 (responseData['message']?.toString().toLowerCase().contains(
//                       'success',
//                     ) ??
//                     false));

//         if (isSuccess) {
//           final bool hasToken = _storeTokenFromResponse(responseData);
//           final bool didAutoLogin = hasToken
//               ? true
//               : await _autoLoginAfterOtpVerification();

//           if (didAutoLogin) {
//             debugPrint('✅ Verify OTP Success + token ready');
//             emit(AuthVerifyOtpSuccessState());
//           } else {
//             emit(
//               AuthVerifyOtpErrorState(
//                 message:
//                     'Phone verified, but login session was not created. Please login.',
//               ),
//             );
//           }
//         } else {
//           emit(
//             AuthVerifyOtpErrorState(
//               message: responseData?['message'] ?? 'Failed to verify OTP',
//             ),
//           );
//         }
//       },
//     );
//   }

//   Future<void> logout() async {
//     emit(AuthLogoutLoadingState());
//     final result = await DioHelper.postData(
//       url: logoutApi,
//       data: {},
//     );

//     result.fold(
//       (failure) {
//         debugPrint('❌ Logout Error: $failure');
//         // Still clear local data even if API fails to ensure user can "logout"
//         _clearLocalAuthData();
//         emit(AuthLogoutSuccessState());
//       },
//       (response) {
//         debugPrint('✅ Logout Success');
//         _clearLocalAuthData();
//         emit(AuthLogoutSuccessState());
//       },
//     );
//   }

//   Future<void> logoutAll() async {
//     emit(AuthLogoutAllLoadingState());
//     final result = await DioHelper.postData(
//       url: logoutAllApi,
//       data: {},
//     );

//     result.fold(
//       (failure) {
//         debugPrint('❌ Logout All Error: $failure');
//         _clearLocalAuthData();
//         emit(AuthLogoutAllSuccessState());
//       },
//       (response) {
//         debugPrint('✅ Logout All Success');
//         _clearLocalAuthData();
//         emit(AuthLogoutAllSuccessState());
//       },
//     );
//   }

//   Future<void> _clearLocalAuthData() async {
//     token = null;
//     userModel = null;
//     await CacheHelper.removeData(key: 'auth_token');
//     await CacheHelper.removeData(key: 'cached_user');
//     ApiService.setToken('');
//     sl<ProfileCubit>().clearData();

//     final context = navigatorKey.currentContext;
//     if (context != null) {
//       NotificationCubit.get(context).clearData();
//     }
//   }

//   void updateUser(UserModel newUser) {
//     userModel = newUser;
//     CacheHelper.saveData(
//       key: 'cached_user',
//       value: jsonEncode(userModel!.toJson()),
//     );
//     emit(AuthUserUpdatedState());
//   }

//   void updateUserAvatar(String? avatar) {
//     if (userModel != null) {
//       userModel = userModel!.copyWith(avatar: avatar);
//       CacheHelper.saveData(
//         key: 'cached_user',
//         value: jsonEncode(userModel!.toJson()),
//       );
//       emit(AuthUserUpdatedState());
//     }
//   }

//   void changeNewPasswordVisibility() {
//     isShowNewPassword = !isShowNewPassword;
//     emit(AuthUpdateUIState());
//   }

//   void changeConfirmNewPasswordVisibility() {
//     isShowConfirmNewPassword = !isShowConfirmNewPassword;
//     emit(AuthUpdateUIState());
//   }

//   Future<void> sendForgotPasswordOtp() async {
//     emit(AuthForgotPasswordLoadingState());
//     debugPrint('🚀 Forgot Password Request Data: {"login": "${forgotLoginController.text.trim()}"}');
//     final result = await DioHelper.postData(
//       url: forgotPasswordApi,
//       data: {'login': forgotLoginController.text.trim()},
//     );
//     result.fold(
//       (failure) {
//         debugPrint('❌ Forgot Password Error: $failure');
//         emit(AuthForgotPasswordErrorState(message: failure.toString()));
//       },
//       (response) {
//         final responseData = response.data as Map<String, dynamic>?;
//         final bool isSuccess =
//             responseData != null &&
//             (responseData['success'] == true ||
//                 (responseData['message']
//                             ?.toString()
//                             .toLowerCase()
//                             .contains('sent') ??
//                         false) ||
//                 (responseData['message']
//                             ?.toString()
//                             .toLowerCase()
//                             .contains('success') ??
//                         false));

//         if (isSuccess) {
//           debugPrint('✅ Forgot Password OTP Sent');
//           emit(AuthForgotPasswordSuccessState());
//         } else {
//           emit(
//             AuthForgotPasswordErrorState(
//               message:
//                   responseData?['message'] ?? 'Failed to send reset code',
//             ),
//           );
//         }
//       },
//     );
//   }

//   Future<void> resetPassword({bool logoutAllDevices = false}) async {
//     final loginValue = forgotLoginController.text.trim().isEmpty 
//         ? emailController.text.trim() 
//         : forgotLoginController.text.trim();
//     final otpValue = resetOtpController.text.trim();

//     if (loginValue.isEmpty || otpValue.isEmpty) {
//       emit(AuthResetPasswordErrorState(
//         message: 'Missing session data (login/OTP). Please restart the recovery flow.',
//       ));
//       return;
//     }

//     emit(AuthResetPasswordLoadingState());
//     final requestData = {
//       'login': loginValue,
//       'otp': otpValue,
//       'password': newPasswordController.text,
//       'password_confirmation': confirmNewPasswordController.text,
//       'logout_all_devices': logoutAllDevices ? 1 : 0,
//     };
//     debugPrint('🚀 Reset Password Request Data: $requestData');

//     final result = await DioHelper.postData(
//       url: resetPasswordApi,
//       data: requestData,
//     );
//     result.fold(
//       (failure) {
//         debugPrint('❌ Reset Password Error: $failure');
//         emit(AuthResetPasswordErrorState(message: failure.toString()));
//       },
//       (response) {
//         final responseData = response.data as Map<String, dynamic>?;
//         final bool isSuccess =
//             responseData != null &&
//             (responseData['success'] == true ||
//                 (responseData['message']
//                             ?.toString()
//                             .toLowerCase()
//                             .contains('success') ??
//                         false));

//         if (isSuccess) {
//           debugPrint('✅ Reset Password Success');
//           resetOtpController.clear();
//           newPasswordController.clear();
//           confirmNewPasswordController.clear();
//           emit(AuthResetPasswordSuccessState());
//         } else {
//           emit(
//             AuthResetPasswordErrorState(
//               message: responseData?['message'] ?? 'Failed to reset password',
//             ),
//           );
//         }
//       },
//     );
//   }

//   void changeCurrentPasswordVisibility() {
//     isShowCurrentPassword = !isShowCurrentPassword;
//     emit(AuthUpdateUIState());
//   }

//   void changeChangePasswordVisibility() {
//     isShowChangePassword = !isShowChangePassword;
//     emit(AuthUpdateUIState());
//   }

//   void changeConfirmChangePasswordVisibility() {
//     isShowConfirmChangePassword = !isShowConfirmChangePassword;
//     emit(AuthUpdateUIState());
//   }

//   Future<void> changePassword({bool logoutAllDevices = false}) async {
//     emit(AuthChangePasswordLoadingState());
//     final requestData = {
//       'current_password': currentPasswordController.text,
//       'password': changePasswordController.text,
//       'password_confirmation': confirmChangePasswordController.text,
//     };
//     debugPrint('🚀 Change Password Request Data: $requestData');

//     final result = await DioHelper.postData(
//       url: changePasswordApi,
//       data: requestData,
//     );

//     result.fold(
//       (failure) {
//         debugPrint('❌ Change Password Error: $failure');
//         emit(AuthChangePasswordErrorState(message: failure.toString()));
//       },
//       (response) async {
//         final responseData = response.data as Map<String, dynamic>?;
//         final bool isSuccess =
//             responseData != null &&
//             (responseData['success'] == true ||
//                 (responseData['message']
//                             ?.toString()
//                             .toLowerCase()
//                             .contains('success') ??
//                         false));

//         if (isSuccess) {
//           debugPrint('✅ Change Password Success');
//           currentPasswordController.clear();
//           changePasswordController.clear();
//           confirmChangePasswordController.clear();
          
//           if (logoutAllDevices) {
//             await logoutAll();
//           } else {
//             emit(AuthChangePasswordSuccessState());
//           }
//         } else {
//           emit(
//             AuthChangePasswordErrorState(
//               message: responseData?['message'] ?? 'Failed to change password',
//             ),
//           );
//         }
//       },
//     );
//   }
// }

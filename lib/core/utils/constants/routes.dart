import 'package:flutter/material.dart';
import 'package:moean/features/home/presentation/screen/home_screen.dart';
import 'package:moean/features/login/presentation/screen/login_screen.dart';
import 'package:moean/features/login/presentation/screen/microsoft_login_screen.dart';
import 'package:moean/features/register/presentation/screen/register_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String loginMicrosoft = '/login/microsoft';


  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    loginMicrosoft: (context) => const MicrosoftLoginScreen(),
  };
}

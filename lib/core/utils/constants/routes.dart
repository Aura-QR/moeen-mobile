import 'package:flutter/material.dart';
import 'package:moean/features/home/presentation/widgets/chose_app.dart';
import 'package:moean/features/home/presentation/widgets/download_extention.dart';
import 'package:moean/features/home/presentation/widgets/extension_usage_slider.dart';
import 'package:moean/features/layout/presentation/screen/main_layout_screen.dart';
import 'package:moean/features/login/presentation/screen/login_screen.dart';
import 'package:moean/features/login/presentation/screen/microsoft_login_screen.dart';
import 'package:moean/features/register/presentation/screen/register_screen.dart';
import 'package:moean/features/schedule/presentation/screen/schedule_screen.dart';
import 'package:moean/features/profile/presentation/screen/profile_screen.dart';
import 'package:moean/features/profile/presentation/screen/settings_screen.dart';
import 'package:moean/features/profile/presentation/screen/change_password_screen.dart';

import 'package:moean/features/admin/teachers/presentation/screen/admin_teachers_screen.dart';
import 'package:moean/features/admin/contact/presentation/screen/admin_contact_screen.dart';
import 'package:moean/features/admin/contact/presentation/screen/admin_ticket_details_screen.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_cubit.dart';
import 'package:moean/features/contact/presentation/screen/contact_support_screen.dart';
import 'package:moean/features/contact/presentation/screen/create_ticket_screen.dart';
import 'package:moean/features/contact/presentation/screen/my_tickets_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/contact/presentation/cubit/contact_cubit.dart';
import 'package:moean/features/contact/presentation/screen/ticket_details_screen.dart';
import 'package:moean/features/reports/presentation/screen/report_screen.dart';
import 'package:moean/features/reports/presentation/cubit/report_cubit.dart';

class Routes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String loginMicrosoft = '/login/microsoft';
  static const String schedule = '/schedule';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String addextention = '/add-extension';
  static const String choseapp = '/chose-app';
  static const String extensionUsage = '/extension-usage';
  static const String adminTeachers = '/admin/teachers';
  static const String adminContact = '/admin/contact';
  static const String adminTicketDetails = '/admin/contact/details';
  static const String contact = '/contact';
  static const String createTicket = '/contact/create-ticket';
  static const String myTickets = '/contact/my-tickets';
  static const String ticketDetails = '/contact/my-tickets/details';
  static const String reports = '/reports';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const MainLayoutScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    loginMicrosoft: (context) => const MicrosoftLoginScreen(),
    schedule: (context) => const ScheduleScreen(),
    profile: (context) => const ProfileScreen(),
    settings: (context) => const SettingsScreen(),
    changePassword: (context) => const ChangePasswordScreen(),
    addextention: (context) => const DownloadExtention(),
    choseapp: (context) => const ChoseApp(),
    extensionUsage: (context) => const ExtensionUsageSlider(),
    adminTeachers: (context) => const AdminTeachersScreen(),
    adminContact: (context) => const AdminContactScreen(),
    adminTicketDetails: (context) => BlocProvider(create: (context) => AdminContactCubit(), child: const AdminTicketDetailsScreen()),
    contact: (context) => BlocProvider(create: (context) => ContactCubit(), child: const ContactSupportScreen()),
    createTicket: (context) => BlocProvider(create: (context) => ContactCubit(), child: const CreateTicketScreen()),
    myTickets: (context) => BlocProvider(create: (context) => ContactCubit(), child: const MyTicketsScreen()),
    ticketDetails: (context) => BlocProvider(create: (context) => ContactCubit(), child: const TicketDetailsScreen()),
    reports: (context) => BlocProvider(create: (_) => ReportCubit(), child: const ReportScreen()),
  };
}

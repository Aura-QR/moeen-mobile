import 'package:flutter/material.dart';
import 'package:moean/core/di/injections.dart';
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
import 'package:moean/features/admin/payments/presentation/screen/admin_payments_screen.dart';
import 'package:moean/features/contact/presentation/screen/contact_support_screen.dart';
import 'package:moean/features/contact/presentation/screen/create_ticket_screen.dart';
import 'package:moean/features/contact/presentation/screen/my_tickets_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/contact/presentation/cubit/contact_cubit.dart';
import 'package:moean/features/contact/presentation/screen/ticket_details_screen.dart';
import 'package:moean/features/reports/presentation/screen/report_screen.dart';
import 'package:moean/features/reports/presentation/cubit/report_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:moean/features/payment/presentation/screen/checkout_screen.dart';
import 'package:moean/features/payment/presentation/screen/bank_transfer_screen.dart';
import 'package:moean/features/payment/presentation/screen/moyasar_payment_screen.dart';
import 'package:moean/features/payment/presentation/screen/payment_result_screen.dart';
import 'package:moean/features/payment/presentation/screen/payment_history_screen.dart';

// Exam Generation Imports
import 'package:moean/features/exam_generation/presentation/screens/exam_info_screen.dart';
import 'package:moean/features/exam_generation/presentation/screens/lesson_selection_screen.dart';
import 'package:moean/features/exam_generation/presentation/screens/question_counts_screen.dart';
import 'package:moean/features/exam_generation/presentation/screens/exam_preview_screen.dart';
import 'package:moean/features/exam_generation/presentation/cubit/exam_info_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/lesson_selection_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/question_count_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/exam_preview_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/generate_exam_cubit.dart';
import 'package:moean/features/exam_generation/presentation/cubit/my_exams_cubit.dart';
import 'package:moean/features/exam_generation/domain/entities/exam_entities.dart';
import 'package:moean/features/exam_generation/presentation/screens/my_exams_screen.dart';
import 'package:moean/features/exam_generation/presentation/screens/custom_questions_screen.dart';
import 'package:moean/features/exam_generation/presentation/cubit/custom_questions_cubit.dart';
import 'package:moean/features/exam_generation/presentation/screens/manual_exam_screen.dart';
import 'package:moean/features/exam_generation/presentation/screens/bank_questions_screen.dart';
import 'package:moean/features/exam_generation/presentation/cubit/bank_questions_cubit.dart';
import 'package:moean/features/admin/exams/presentation/screen/admin_exams_screen.dart';
import 'package:moean/features/admin/exams/presentation/cubit/admin_exams_cubit.dart';
import 'package:moean/features/search/presentation/screen/search_screen.dart';
import 'package:moean/features/search/presentation/cubit/search_cubit.dart';
import 'package:moean/features/certificates/presentation/screens/certificate_screen.dart';
import 'package:moean/features/certificates/presentation/cubit/certificate_cubit.dart';
import 'package:moean/features/presentations/presentation/screens/presentations_screen.dart';
import 'package:moean/features/presentations/presentation/cubit/presentations_cubit.dart';
import 'package:moean/features/presentations/data/repositories/presentations_repository.dart';

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
  static const String adminPayments = '/admin/payments';
  static const String contact = '/contact';
  static const String createTicket = '/contact/create-ticket';
  static const String myTickets = '/contact/my-tickets';
  static const String ticketDetails = '/contact/my-tickets/details';
  static const String reports = '/reports';
  static const String checkout = '/checkout';
  static const String bankTransfer = '/bank-transfer';
  static const String moyasarPayment = '/moyasar-payment';
  static const String paymentResult = '/payment-result';
  static const String paymentHistory = '/payment-history';
  
  // Exam Generation
  static const String examGenerationInfo = '/exam-generation/info';
  static const String examGenerationLessons = '/exam-generation/lessons';
  static const String examGenerationCounts = '/exam-generation/counts';
  static const String examGenerationPreview = '/exam-generation/preview';
  static const String myExams = '/my-exams';
  static const String customQuestions = '/my-custom-questions';
  static const String manualExam = '/manual-exam';
  static const String examBankQuestions = '/exam-generation/bank-questions';
  static const String adminExams = '/admin/exams';
  static const String search = '/search';
  static const String certificates = '/certificates';
  static const String presentations = '/presentations';

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
    adminPayments: (context) => const AdminPaymentsScreen(),
    adminExams: (context) => BlocProvider(create: (_) => sl<AdminExamsCubit>()..fetchPendingQuestions(), child: const AdminExamsScreen()),
    contact: (context) => BlocProvider(create: (context) => ContactCubit(), child: const ContactSupportScreen()),
    createTicket: (context) => BlocProvider(create: (context) => ContactCubit(), child: const CreateTicketScreen()),
    myTickets: (context) => BlocProvider(create: (context) => ContactCubit(), child: const MyTicketsScreen()),
    ticketDetails: (context) => BlocProvider(create: (context) => ContactCubit(), child: const TicketDetailsScreen()),
    reports: (context) => BlocProvider(create: (_) => ReportCubit(), child: const ReportScreen()),
    checkout: (context) => BlocProvider(create: (_) => PaymentCubit(), child: const CheckoutScreen()),
    bankTransfer: (context) => BlocProvider(create: (_) => PaymentCubit(), child: const BankTransferScreen()),
    moyasarPayment: (context) => BlocProvider(create: (_) => PaymentCubit(), child: const MoyasarPaymentScreen()),
    paymentResult: (context) => const PaymentResultScreen(),
    paymentHistory: (context) => BlocProvider(create: (_) => PaymentCubit(), child: const PaymentHistoryScreen()),
    examGenerationInfo: (context) => BlocProvider.value(value: sl<ExamInfoCubit>(), child: const ExamInfoScreen()),
    examGenerationLessons: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<LessonSelectionCubit>()),
        BlocProvider.value(value: sl<ExamInfoCubit>()),
      ],
      child: const LessonSelectionScreen(),
    ),
    examGenerationCounts: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<QuestionCountCubit>()),
        BlocProvider(create: (_) => sl<GenerateExamCubit>()),
        BlocProvider.value(value: sl<LessonSelectionCubit>()),
        BlocProvider.value(value: sl<ExamInfoCubit>()),
      ],
      child: const QuestionCountsScreen(),
    ),
    myExams: (context) => BlocProvider(
      create: (_) => sl<MyExamsCubit>(),
      child: const MyExamsScreen(),
    ),
    customQuestions: (context) => BlocProvider(
      create: (_) => sl<CustomQuestionsCubit>(),
      child: const CustomQuestionsScreen(),
    ),
    examGenerationPreview: (context) {
      final initialExam = ModalRoute.of(context)!.settings.arguments as ExamEntity;
      return BlocProvider(
        create: (_) => sl<ExamPreviewCubit>(),
        child: ExamPreviewScreen(initialExam: initialExam),
      );
    },
    manualExam: (context) => const ManualExamScreen(),
    search: (context) => BlocProvider(
      create: (_) => SearchCubit(),
      child: const SearchScreen(),
    ),
    certificates: (context) => BlocProvider(
      create: (_) => CertificateCubit(),
      child: const CertificateScreen(),
    ),
    examBankQuestions: (context) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<BankQuestionsCubit>()),
        BlocProvider.value(value: sl<LessonSelectionCubit>()),
        BlocProvider.value(value: sl<ExamInfoCubit>()),
      ],
      child: const BankQuestionsScreen(),
    ),
    presentations: (context) => BlocProvider(
      create: (_) => PresentationsCubit(PresentationsRepository()),
      child: const PresentationsScreen(),
    ),
  };
}

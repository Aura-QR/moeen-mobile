import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/models/login_request.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_state.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountSuspendedCubit extends Cubit<AccountSuspendedState> {
  static AccountSuspendedCubit get(BuildContext context) =>
      BlocProvider.of<AccountSuspendedCubit>(context);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController subjectController = TextEditingController(
    text: 'طلب مراجعة وفك تعليق الحساب',
  );
  final TextEditingController messageController = TextEditingController();

  AccountSuspendedCubit() : super(AccountSuspendedInitialState()) {
    try {
      subjectController.text = appTranslation().get('account_suspended_subject_default');
    } catch (_) {}
  }

  String selectedType = 'technical_support';
  List<dynamic> contactTypes = [
    {'value': 'technical_support', 'label': 'دعم فني'},
    {'value': 'billing', 'label': 'الفوترة والاشتراكات'},
    {'value': 'feature_request', 'label': 'اقتراح ميزة'},
    {'value': 'general', 'label': 'استفسار عام'},
    {'value': 'other', 'label': 'أخرى'},
  ];

  Future<void> loadContactTypes() async {
    final result = await ApiService.getContactTypes();
    if (isClosed) return;
    result.fold(
      (_) {},
      (data) {
        if (data['types'] is List && (data['types'] as List).isNotEmpty) {
          contactTypes = data['types'] as List;
          if (!isClosed) {
            emit(AccountSuspendedTypesLoadedState(types: contactTypes));
          }
        }
      },
    );
  }

  void selectType(String type) {
    selectedType = type;
    emit(AccountSuspendedTypeSelectedState(selectedType: type));
  }

  Future<void> checkStatus({String? email, String? password}) async {
    if (!isClosed) emit(AccountSuspendedCheckingState());

    if (email != null && email.isNotEmpty && password != null && password.isNotEmpty) {
      final result = await ApiService.loginUser(
        LoginRequest(email: email, password: password),
      );
      if (isClosed) return;

      result.fold(
        (error) {
          if (!isClosed) {
            final isSuspended = error.contains('account_suspended') ||
                error.contains('تعليق') ||
                error.contains('موقوف');
            if (isSuspended) {
              emit(
                AccountSuspendedStillSuspendedState(
                  message: appTranslation().get('account_suspended_still_suspended'),
                ),
              );
            } else {
              emit(AccountSuspendedStillSuspendedState(message: error));
            }
          }
        },
        (response) {
          if (!isClosed) {
            if (response.user.isActive) {
              emit(AccountSuspendedActiveState());
            } else {
              emit(
                AccountSuspendedStillSuspendedState(
                  message: appTranslation().get('account_suspended_still_suspended'),
                ),
              );
            }
          }
        },
      );
      return;
    }

    final meResult = await ApiService.getMe();
    if (isClosed) return;

    meResult.fold(
      (error) {
        if (!isClosed) {
          emit(
            AccountSuspendedStillSuspendedState(
              message: appTranslation().get('account_suspended_still_suspended'),
            ),
          );
        }
      },
      (user) {
        if (!isClosed) {
          if (user.isActive) {
            emit(AccountSuspendedActiveState());
          } else {
            emit(
              AccountSuspendedStillSuspendedState(
                message: appTranslation().get('account_suspended_still_suspended'),
              ),
            );
          }
        }
      },
    );
  }

  Future<void> submitReviewTicket({
    String? email,
    String? name,
    String? phone,
  }) async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (!isClosed) emit(AccountSuspendedTicketSubmittingState());

    final subject = subjectController.text.trim();
    final messageDetails = messageController.text.trim();
    final combinedMessage = subject.isNotEmpty
        ? '$subject\n$messageDetails'
        : messageDetails;

    final result = await ApiService.submitContactRequest(
      name: (name != null && name.isNotEmpty) ? name : 'مستخدم معلق',
      email: (email != null && email.isNotEmpty) ? email : 'suspended@user.com',
      phone: phone,
      type: selectedType,
      message: combinedMessage,
    );

    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AccountSuspendedTicketErrorState(message: error));
      },
      (_) {
        messageController.clear();
        if (!isClosed) {
          emit(
            AccountSuspendedTicketSuccessState(
              message: appTranslation().get('account_suspended_ticket_sent_success'),
            ),
          );
        }
      },
    );
  }

  Future<void> launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedPhone = cleanPhone.startsWith('0')
        ? '966${cleanPhone.substring(1)}'
        : cleanPhone;
    final uri = Uri.parse('https://wa.me/$formattedPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> launchEmail(String email, {String? subject, String? body}) async {
    final defaultSubject = 'طلب مراجعة وفك تعليق الحساب';
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject ?? defaultSubject)}',
    );
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (_) {
      try {
        await launchUrl(uri);
      } catch (_) {}
    }
  }

  Future<void> launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Future<void> close() {
    subjectController.dispose();
    messageController.dispose();
    return super.close();
  }
}

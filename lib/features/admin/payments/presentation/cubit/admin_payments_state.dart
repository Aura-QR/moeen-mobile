import 'package:moean/features/payment/data/models/payment_model.dart';

abstract class AdminPaymentsState {}

class AdminPaymentsInitial extends AdminPaymentsState {}

class GetAdminPaymentsLoadingState extends AdminPaymentsState {}

class GetAdminPaymentsSuccessState extends AdminPaymentsState {}

class GetAdminPaymentsErrorState extends AdminPaymentsState {
  final String message;
  GetAdminPaymentsErrorState(this.message);
}

class AdminPaymentActionLoadingState extends AdminPaymentsState {}

class AdminPaymentActionSuccessState extends AdminPaymentsState {
  final String message;
  AdminPaymentActionSuccessState(this.message);
}

class AdminPaymentActionErrorState extends AdminPaymentsState {
  final String message;
  AdminPaymentActionErrorState(this.message);
}

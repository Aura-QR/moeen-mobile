import 'package:moean/features/payment/data/models/order_model.dart';
import 'package:moean/features/payment/data/models/payment_model.dart';
import 'package:moean/features/payment/data/models/subscription_plan_model.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

// Plans
class PlansLoading extends PaymentState {}
class PlansLoaded extends PaymentState {
  final List<SubscriptionPlanModel> plans;
  PlansLoaded(this.plans);
}
class PlansError extends PaymentState {
  final String error;
  PlansError(this.error);
}

// Order
class OrderCreating extends PaymentState {}
class OrderCreated extends PaymentState {
  final OrderModel order;
  OrderCreated(this.order);
}
class OrderError extends PaymentState {
  final String error;
  OrderError(this.error);
}

// Bank Info
class BankInfoLoading extends PaymentState {}
class BankInfoLoaded extends PaymentState {
  final Map<String, dynamic> data;
  BankInfoLoaded(this.data);
}
class BankInfoError extends PaymentState {
  final String error;
  BankInfoError(this.error);
}

// Receipt Upload
class ReceiptUploading extends PaymentState {}
class ReceiptUploaded extends PaymentState {
  final PaymentModel payment;
  ReceiptUploaded(this.payment);
}
class ReceiptUploadError extends PaymentState {
  final String error;
  ReceiptUploadError(this.error);
}

// Moyasar Config
class MoyasarConfigLoading extends PaymentState {}
class MoyasarConfigLoaded extends PaymentState {
  final Map<String, dynamic> config;
  MoyasarConfigLoaded(this.config);
}
class MoyasarConfigError extends PaymentState {
  final String error;
  MoyasarConfigError(this.error);
}

// Payment Verification
class PaymentVerifying extends PaymentState {}
class PaymentVerified extends PaymentState {
  final PaymentModel payment;
  PaymentVerified(this.payment);
}
class PaymentVerifyError extends PaymentState {
  final String error;
  PaymentVerifyError(this.error);
}

// History
class HistoryLoading extends PaymentState {}
class HistoryLoaded extends PaymentState {
  final List<PaymentModel> history;
  HistoryLoaded(this.history);
}
class HistoryError extends PaymentState {
  final String error;
  HistoryError(this.error);
}

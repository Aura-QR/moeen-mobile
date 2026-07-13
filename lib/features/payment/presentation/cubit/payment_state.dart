import 'package:flutter/material.dart';
import 'package:moean/features/payment/data/models/order_model.dart';
import 'package:moean/features/payment/data/models/payment_model.dart';
import 'package:moean/features/payment/data/models/subscription_plan_model.dart';

@immutable
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

// Order creation
class OrderCreating extends PaymentState {}

class OrderCreated extends PaymentState {
  final OrderModel order;
  OrderCreated(this.order);
}

class OrderError extends PaymentState {
  final String error;
  OrderError(this.error);
}

// Checkout (Moyasar config)
class CheckoutLoading extends PaymentState {}

class CheckoutLoaded extends PaymentState {
  final Map<String, dynamic> config;
  CheckoutLoaded(this.config);
}

class CheckoutError extends PaymentState {
  final String error;
  CheckoutError(this.error);
}

// Bank transfer info
class BankInfoLoading extends PaymentState {}

class BankInfoLoaded extends PaymentState {
  final Map<String, dynamic> info;
  BankInfoLoaded(this.info);
}

class BankInfoError extends PaymentState {
  final String error;
  BankInfoError(this.error);
}

// Receipt upload
class ReceiptUploading extends PaymentState {}

class ReceiptUploaded extends PaymentState {
  final PaymentModel payment;
  ReceiptUploaded(this.payment);
}

class ReceiptUploadError extends PaymentState {
  final String error;
  ReceiptUploadError(this.error);
}

// Payment verification
class PaymentVerifying extends PaymentState {}

class PaymentVerified extends PaymentState {
  final PaymentModel payment;
  PaymentVerified(this.payment);
}

class PaymentVerifyError extends PaymentState {
  final String error;
  PaymentVerifyError(this.error);
}

// Payment history
class HistoryLoading extends PaymentState {}

class HistoryLoaded extends PaymentState {
  final List<PaymentModel> payments;
  HistoryLoaded(this.payments);
}

class HistoryError extends PaymentState {
  final String error;
  HistoryError(this.error);
}

import 'package:moean/features/payment/data/models/order_model.dart';

class PaymentModel {
  final int id;
  final int orderId;
  final String paymentMethod;
  final String? gateway;
  final String? moyasarPaymentId;
  final String amount;
  final String currency;
  final String status;
  final String? paidAt;
  final String? verifiedAt;
  final String? receiptPath;
  final String? createdAt;
  final OrderModel? order;

  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    this.gateway,
    this.moyasarPaymentId,
    required this.amount,
    required this.currency,
    required this.status,
    this.paidAt,
    this.verifiedAt,
    this.receiptPath,
    this.createdAt,
    this.order,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int? ?? 0,
      paymentMethod: json['payment_method'] as String? ?? '',
      gateway: json['gateway'] as String?,
      moyasarPaymentId: json['moyasar_payment_id'] as String?,
      amount: json['amount'] as String? ?? '0',
      currency: json['currency'] as String? ?? 'SAR',
      status: json['status'] as String? ?? 'pending',
      paidAt: json['paid_at'] as String?,
      verifiedAt: json['verified_at'] as String?,
      receiptPath: json['receipt_path'] as String?,
      createdAt: json['created_at'] as String?,
      order: json['order'] != null
          ? OrderModel.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }
}

import 'package:moean/features/payment/data/models/subscription_plan_model.dart';

class OrderModel {
  final int id;
  final int serviceId;
  final String amount;
  final String currency;
  final String status;
  final SubscriptionPlanModel? service;

  const OrderModel({
    required this.id,
    required this.serviceId,
    required this.amount,
    required this.currency,
    required this.status,
    this.service,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      serviceId: json['service_id'] as int? ?? 0,
      amount: json['amount'] as String? ?? '0',
      currency: json['currency'] as String? ?? 'SAR',
      status: json['status'] as String? ?? 'pending',
      service: json['service'] != null
          ? SubscriptionPlanModel.fromJson(
              json['service'] as Map<String, dynamic>)
          : null,
    );
  }
}

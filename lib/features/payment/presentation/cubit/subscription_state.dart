import 'package:moean/features/payment/data/models/subscription_current_model.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}
class SubscriptionLoading extends SubscriptionState {}
class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionCurrentModel current;
  SubscriptionLoaded(this.current);
}
class SubscriptionError extends SubscriptionState {
  final String error;
  SubscriptionError(this.error);
}

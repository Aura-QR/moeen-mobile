import 'package:moean/features/payment/data/models/subscription_current_model.dart';
import 'package:moean/features/payment/data/models/subscription_plan_model.dart';

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

class SubscriptionUpgradeLoading extends SubscriptionState {}
class SubscriptionUpgradeSuccess extends SubscriptionState {
  final String message;
  SubscriptionUpgradeSuccess(this.message);
}
class SubscriptionUpgradeError extends SubscriptionState {
  final String error;
  SubscriptionUpgradeError(this.error);
}

// Available plans
class SubscriptionPlansLoading extends SubscriptionState {}
class SubscriptionPlansLoaded extends SubscriptionState {
  final List<SubscriptionPlanModel> plans;
  SubscriptionPlansLoaded(this.plans);
}
class SubscriptionPlansError extends SubscriptionState {
  final String error;
  SubscriptionPlansError(this.error);
}

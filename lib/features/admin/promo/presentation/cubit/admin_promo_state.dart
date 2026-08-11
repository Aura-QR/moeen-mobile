import 'package:moean/features/admin/promo/data/models/admin_promo_models.dart';

abstract class AdminPromoState {}

class AdminPromoInitial extends AdminPromoState {}

class AdminPromoLoading extends AdminPromoState {}

class AdminPromoLoaded extends AdminPromoState {
  final AdminReferralStatsModel stats;
  final List<AdminPromoCodeModel> promoCodes;
  AdminPromoLoaded({required this.stats, required this.promoCodes});
}

class AdminPromoError extends AdminPromoState {
  final String error;
  AdminPromoError(this.error);
}

// Actions
class AdminPromoActionLoading extends AdminPromoState {}

class AdminPromoActionSuccess extends AdminPromoState {
  final String message;
  AdminPromoActionSuccess(this.message);
}

class AdminPromoActionError extends AdminPromoState {
  final String error;
  AdminPromoActionError(this.error);
}

class AdminPromoCreating extends AdminPromoState {}

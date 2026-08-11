import 'package:moean/features/referral/data/models/referral_dashboard_model.dart';

abstract class ReferralState {}

class ReferralInitial extends ReferralState {}

class ReferralLoading extends ReferralState {}

class ReferralLoaded extends ReferralState {
  final ReferralDashboardModel dashboard;
  ReferralLoaded(this.dashboard);
}

class ReferralError extends ReferralState {
  final String error;
  ReferralError(this.error);
}

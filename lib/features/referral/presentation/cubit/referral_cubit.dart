import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/referral/data/models/referral_dashboard_model.dart';
import 'package:moean/features/referral/presentation/cubit/referral_state.dart';

class ReferralCubit extends Cubit<ReferralState> {
  ReferralCubit() : super(ReferralInitial());

  static ReferralCubit get(BuildContext context) => BlocProvider.of(context);

  ReferralDashboardModel? dashboard;

  Future<void> loadDashboard() async {
    if (!isClosed) emit(ReferralLoading());
    final result = await ApiService.getReferralDashboard();
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(ReferralError(error));
      },
      (data) {
        dashboard = ReferralDashboardModel.fromJson(data);
        if (!isClosed) emit(ReferralLoaded(dashboard!));
      },
    );
  }

  Future<void> refresh() => loadDashboard();
}

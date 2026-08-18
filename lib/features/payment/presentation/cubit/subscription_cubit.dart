import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_state.dart';
import 'package:moean/features/payment/data/models/subscription_current_model.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit() : super(SubscriptionInitial());

  static SubscriptionCubit get(BuildContext context) => BlocProvider.of(context);

  SubscriptionCurrentModel? currentSubscription;
  bool _isLoading = false;

  Future<void> fetchCurrentSubscription({bool forceRefresh = false}) async {
    if (token == null || token!.isEmpty) return;
    if (_isLoading) return;

    if (!forceRefresh && currentSubscription != null) {
      if (state is! SubscriptionLoaded) {
        if (!isClosed) emit(SubscriptionLoaded(currentSubscription!));
      }
      return;
    }

    _isLoading = true;
    if (currentSubscription == null && !isClosed) {
      emit(SubscriptionLoading());
    }

    final result = await ApiService.getCurrentSubscription();
    _isLoading = false;
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(SubscriptionError(error));
      },
      (data) {
        final current = SubscriptionCurrentModel.fromJson(data);
        currentSubscription = current;
        if (!isClosed) emit(SubscriptionLoaded(current));
      },
    );
  }

  void clearData() {
    currentSubscription = null;
    if (!isClosed) emit(SubscriptionInitial());
  }

  Future<void> upgradeSubscription({required String planSlug, String? promoCode}) async {
    if (!isClosed) emit(SubscriptionUpgradeLoading());
    final result = await ApiService.upgradeSubscription(planSlug: planSlug, promoCode: promoCode);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(SubscriptionUpgradeError(error));
      },
      (data) {
        if (!isClosed) emit(SubscriptionUpgradeSuccess(data['message'] ?? 'تم الترقية بنجاح'));
        fetchCurrentSubscription(forceRefresh: true); // Refresh after upgrade
      },
    );
  }
}

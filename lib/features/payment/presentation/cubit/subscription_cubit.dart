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
  String? lastError;
  bool _isLoading = false;

  Future<void> fetchCurrentSubscription({bool forceRefresh = false}) async {
    if (token == null || token!.isEmpty) return;
    if (_isLoading) return;

    if (!forceRefresh && (currentSubscription != null || lastError != null)) {
      if (currentSubscription != null && state is! SubscriptionLoaded) {
        if (!isClosed) emit(SubscriptionLoaded(currentSubscription!));
      } else if (lastError != null && state is! SubscriptionError) {
        if (!isClosed) emit(SubscriptionError(lastError!));
      }
      return;
    }

    _isLoading = true;
    if (!isClosed) {
      if (forceRefresh) {
        currentSubscription = null;
        lastError = null;
        emit(SubscriptionLoading());
      } else if (currentSubscription == null && lastError == null) {
        emit(SubscriptionLoading());
      }
    }

    final result = await ApiService.getCurrentSubscription();
    _isLoading = false;
    if (isClosed) return;

    result.fold(
      (error) {
        lastError = error;
        if (!isClosed) emit(SubscriptionError(error));
      },
      (data) {
        lastError = null;
        final current = SubscriptionCurrentModel.fromJson(data);
        currentSubscription = current;
        if (!isClosed) emit(SubscriptionLoaded(current));
      },
    );
  }

  void clearData() {
    currentSubscription = null;
    lastError = null;
    _isLoading = false;
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

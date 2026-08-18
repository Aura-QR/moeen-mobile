import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/admin/promo/data/models/admin_promo_models.dart';
import 'package:moean/features/admin/promo/presentation/cubit/admin_promo_state.dart';

class AdminPromoCubit extends Cubit<AdminPromoState> {
  AdminPromoCubit() : super(AdminPromoInitial());

  static AdminPromoCubit get(BuildContext context) => BlocProvider.of(context);

  AdminReferralStatsModel? stats;
  List<AdminPromoCodeModel> promoCodes = [];

  Future<void> loadAll() async {
    if (!isClosed) emit(AdminPromoLoading());
    final statsResult = await ApiService.getAdminReferralStats();
    final promoResult = await ApiService.getAdminPromoCodes();
    if (isClosed) return;

    statsResult.fold(
      (error) {
        if (!isClosed) emit(AdminPromoError(error));
      },
      (statsData) {
        promoResult.fold(
          (error) {
            if (!isClosed) emit(AdminPromoError(error));
          },
          (promoData) {
            stats = AdminReferralStatsModel.fromJson(statsData);
            final list = promoData['data'] as List<dynamic>? ?? [];
            promoCodes = list
                .map((e) => AdminPromoCodeModel.fromJson(e as Map<String, dynamic>))
                .toList();
            if (!isClosed) emit(AdminPromoLoaded(stats: stats!, promoCodes: promoCodes));
          },
        );
      },
    );
  }

  Future<void> createPromoCode(Map<String, dynamic> data) async {
    if (!isClosed) emit(AdminPromoCreating());
    final result = await ApiService.createAdminPromoCode(data);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(AdminPromoActionError(error));
      },
      (_) {
        if (!isClosed) emit(AdminPromoActionSuccess(appTranslation().get('admin_promo_success_create')));
        loadAll();
      },
    );
  }

  Future<void> togglePromoCode(AdminPromoCodeModel promo) async {
    if (!isClosed) emit(AdminPromoActionLoading());
    final result = promo.isActive
        ? await ApiService.deactivateAdminPromoCode(promo.id)
        : await ApiService.activateAdminPromoCode(promo.id);
    if (isClosed) return;

    result.fold(
      (error) {
        if (!isClosed) emit(AdminPromoActionError(error));
      },
      (_) {
        final msg = promo.isActive
            ? appTranslation().get('admin_promo_success_deactivate')
            : appTranslation().get('admin_promo_success_activate');
        if (!isClosed) emit(AdminPromoActionSuccess(msg));
        loadAll();
      },
    );
  }

  Future<void> deletePromoCode(int id) async {
    if (!isClosed) emit(AdminPromoActionLoading());
    final result = await ApiService.deleteAdminPromoCode(id);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(AdminPromoActionError(error));
      },
      (_) {
        if (!isClosed) emit(AdminPromoActionSuccess(appTranslation().get('admin_promo_success_delete')));
        loadAll();
      },
    );
  }
}

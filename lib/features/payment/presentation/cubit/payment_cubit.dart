import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/payment/data/models/order_model.dart';
import 'package:moean/features/payment/data/models/payment_model.dart';
import 'package:moean/features/payment/data/models/subscription_plan_model.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_cubit.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  static PaymentCubit get(BuildContext context) => BlocProvider.of(context);

  List<SubscriptionPlanModel> plans = [];
  OrderModel? currentOrder;
  Map<String, dynamic>? bankInfo;
  List<PaymentModel> paymentHistory = [];
  int selectedPlanIndex = 0;
  int selectedMethodIndex = 0;
  String? appliedPromoCode;
  Map<String, dynamic>? promoValidation;

  Future<void> loadPlans() async {
    if (!isClosed) emit(PlansLoading());
    final result = await ApiService.getSubscriptions();
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(PlansError(error));
      },
      (data) {
        plans = data
            .map((e) =>
                SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
            .where((p) => double.tryParse(p.price) != null &&
                double.parse(p.price) > 0 && double.parse(p.price) != 1)
            .toList();
        if (!isClosed) emit(PlansLoaded(plans));
      },
    );
  }

  void selectPlan(int index) {
    selectedPlanIndex = index;
    if (!isClosed) emit(PlansLoaded(plans));
  }

  void selectMethod(int index) {
    selectedMethodIndex = index;
    if (!isClosed) emit(PlansLoaded(plans));
  }

  Future<void> createOrder() async {
    if (plans.isEmpty) return;
    if (!isClosed) emit(OrderCreating());
    final serviceId = plans[selectedPlanIndex].id;
    final result = await ApiService.createOrder(
      serviceId,
      promoCode: appliedPromoCode,
    );
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(OrderError(error));
      },
      (data) {
        currentOrder = OrderModel.fromJson(
            data['order'] as Map<String, dynamic>);
        if (!isClosed) emit(OrderCreated(currentOrder!));
      },
    );
  }

  Future<void> validatePromo(String code) async {
    if (plans.isEmpty || code.trim().isEmpty) return;
    final planSlug = plans[selectedPlanIndex].slug;
    if (!isClosed) emit(PromoValidating());
    final result = await ApiService.validatePromoCode(
      code: code.trim(),
      planSlug: planSlug,
    );
    if (isClosed) return;
    result.fold(
      (error) {
        appliedPromoCode = null;
        promoValidation = null;
        if (!isClosed) emit(PromoError(error));
      },
      (data) {
        appliedPromoCode = code.trim();
        promoValidation = data;
        if (!isClosed) emit(PromoValidated(data));
      },
    );
  }

  void clearPromo() {
    appliedPromoCode = null;
    promoValidation = null;
    if (!isClosed) emit(PromoCleared());
  }

  Future<void> loadBankInfo() async {
    if (!isClosed) emit(BankInfoLoading());
    final result = await ApiService.getBankTransferInfo();
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(BankInfoError(error));
      },
      (data) {
        bankInfo = data;
        if (!isClosed) emit(BankInfoLoaded(data));
      },
    );
  }

  // Moyasar Flow
  Future<void> getMoyasarConfig(int orderId) async {
    if (!isClosed) emit(MoyasarConfigLoading());
    final result = await ApiService.getOrderCheckout(orderId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(MoyasarConfigError(error));
      },
      (data) {
        if (!isClosed) emit(MoyasarConfigLoaded(data));
      },
    );
  }

  // MyFatoorah Flow
  Future<void> initMyfatoorahPayment(int orderId) async {
    if (!isClosed) emit(MyfatoorahSessionLoading());
    final result = await ApiService.createMyfatoorahSession(orderId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(MyfatoorahSessionError(error));
      },
      (data) {
        if (!isClosed) emit(MyfatoorahSessionLoaded(data));
      },
    );
  }

  Future<void> executeMyfatoorahPayment(int orderId, String sessionId) async {
    if (!isClosed) emit(MyfatoorahExecuteLoading());
    final result = await ApiService.executeMyfatoorahPayment(orderId: orderId, sessionId: sessionId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(MyfatoorahExecuteError(error));
      },
      (data) {
        sl<SubscriptionCubit>().fetchCurrentSubscription();
        if (!isClosed) emit(MyfatoorahExecuteLoaded(data));
      },
    );
  }

  Future<void> verifyMyfatoorahPayment(String paymentKey) async {
    if (!isClosed) emit(PaymentVerifying());
    final result = await ApiService.verifyMyfatoorahPayment(
      key: paymentKey,
    );
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(PaymentVerifyError(error));
      },
      (data) {
        final payment = PaymentModel.fromJson(
            data['payment'] as Map<String, dynamic>);
        
        // Refresh subscription state globally
        sl<SubscriptionCubit>().fetchCurrentSubscription();
        
        if (!isClosed) emit(PaymentVerified(payment));
      },
    );
  }

  Future<void> verifyPayment(String paymentId, {int? orderId}) async {
    if (!isClosed) emit(PaymentVerifying());
    
    // إذا كان لدينا orderId، نقوم بحفظ المرجع أولاً (حسب المستند)
    if (orderId != null) {
      await ApiService.savePaymentReference(
        orderId: orderId,
        moyasarPaymentId: paymentId,
      );
    }

    final result = await ApiService.verifyPayment(paymentId);
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(PaymentVerifyError(error));
      },
      (data) {
        final payment = PaymentModel.fromJson(
            data['payment'] as Map<String, dynamic>);
        
        // Refresh subscription state globally
        sl<SubscriptionCubit>().fetchCurrentSubscription();
        
        if (!isClosed) emit(PaymentVerified(payment));
      },
    );
  }

  Future<void> uploadReceiptForOrder({
    required int orderId,
    required String filePath,
    required String fileName,
  }) async {
    if (!isClosed) emit(ReceiptUploading());
    final result = await ApiService.uploadManualReceipt(
      orderId: orderId,
      filePath: filePath,
      fileName: fileName,
    );
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(ReceiptUploadError(error));
      },
      (data) {
        final payment = PaymentModel.fromJson(
            data['payment'] as Map<String, dynamic>);
        if (!isClosed) emit(ReceiptUploaded(payment));
      },
    );
  }

  Future<void> loadHistory() async {
    if (!isClosed) emit(HistoryLoading());
    final result = await ApiService.getPaymentHistory();
    if (isClosed) return;
    result.fold(
      (error) {
        if (!isClosed) emit(HistoryError(error));
      },
      (data) {
        final list = (data['data'] as List<dynamic>? ?? [])
            .map((e) =>
                PaymentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        paymentHistory = list;
        if (!isClosed) emit(HistoryLoaded(list));
      },
    );
  }
}

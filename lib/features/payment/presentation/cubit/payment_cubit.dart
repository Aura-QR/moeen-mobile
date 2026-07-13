import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/network/remote/api_service.dart';
import 'package:moean/features/payment/data/models/order_model.dart';
import 'package:moean/features/payment/data/models/payment_model.dart';
import 'package:moean/features/payment/data/models/subscription_plan_model.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  static PaymentCubit get(context) => BlocProvider.of(context);

  List<SubscriptionPlanModel> plans = [];
  OrderModel? currentOrder;
  Map<String, dynamic>? bankInfo;
  List<PaymentModel> paymentHistory = [];
  int selectedPlanIndex = 0;
  // 0 = moyasar (online), 1 = manual_bank_transfer
  int selectedMethodIndex = 0;

  Future<void> loadPlans() async {
    emit(PlansLoading());
    final result = await ApiService.getSubscriptions();
    result.fold(
      (error) => emit(PlansError(error)),
      (data) {
        plans = data
            .map((e) =>
                SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
            .where((p) => double.tryParse(p.price) != null &&
                double.parse(p.price) > 0)
            .toList();
        emit(PlansLoaded(plans));
      },
    );
  }

  void selectPlan(int index) {
    selectedPlanIndex = index;
    emit(PlansLoaded(plans));
  }

  void selectMethod(int index) {
    selectedMethodIndex = index;
    if (currentOrder != null) {
      emit(OrderCreated(currentOrder!));
    }
  }

  Future<void> createOrder() async {
    if (plans.isEmpty) return;
    emit(OrderCreating());
    final serviceId = plans[selectedPlanIndex].id;
    final result = await ApiService.createOrder(serviceId);
    result.fold(
      (error) => emit(OrderError(error)),
      (data) {
        currentOrder = OrderModel.fromJson(
            data['order'] as Map<String, dynamic>);
        emit(OrderCreated(currentOrder!));
      },
    );
  }

  Future<void> loadBankInfo() async {
    emit(BankInfoLoading());
    final result = await ApiService.getBankTransferInfo();
    result.fold(
      (error) => emit(BankInfoError(error)),
      (data) {
        bankInfo = data;
        emit(BankInfoLoaded(data));
      },
    );
  }

  Future<void> uploadReceipt({
    required String filePath,
    required String fileName,
  }) async {
    if (currentOrder == null) return;
    emit(ReceiptUploading());
    final result = await ApiService.uploadManualReceipt(
      orderId: currentOrder!.id,
      filePath: filePath,
      fileName: fileName,
    );
    result.fold(
      (error) => emit(ReceiptUploadError(error)),
      (data) {
        final payment = PaymentModel.fromJson(
            data['payment'] as Map<String, dynamic>);
        emit(ReceiptUploaded(payment));
      },
    );
  }

  Future<void> uploadReceiptForOrder({
    required int orderId,
    required String filePath,
    required String fileName,
  }) async {
    emit(ReceiptUploading());
    final result = await ApiService.uploadManualReceipt(
      orderId: orderId,
      filePath: filePath,
      fileName: fileName,
    );
    result.fold(
      (error) => emit(ReceiptUploadError(error)),
      (data) {
        final payment = PaymentModel.fromJson(
            data['payment'] as Map<String, dynamic>);
        emit(ReceiptUploaded(payment));
      },
    );
  }

  Future<void> verifyPayment(String paymentId) async {
    emit(PaymentVerifying());
    final result = await ApiService.verifyPayment(paymentId);
    result.fold(
      (error) => emit(PaymentVerifyError(error)),
      (data) {
        final payment = PaymentModel.fromJson(
            data['payment'] as Map<String, dynamic>);
        emit(PaymentVerified(payment));
      },
    );
  }

  Future<void> loadHistory() async {
    emit(HistoryLoading());
    final result = await ApiService.getPaymentHistory();
    result.fold(
      (error) => emit(HistoryError(error)),
      (data) {
        final list = (data['data'] as List<dynamic>? ?? [])
            .map((e) =>
                PaymentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        paymentHistory = list;
        emit(HistoryLoaded(list));
      },
    );
  }
}

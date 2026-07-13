import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/admin/payments/data/repositories/admin_payments_repository.dart';
import 'package:moean/features/admin/payments/presentation/cubit/admin_payments_state.dart';
import 'package:moean/features/payment/data/models/payment_model.dart';

class AdminPaymentsCubit extends Cubit<AdminPaymentsState> {
  final AdminPaymentsRepository repository;

  AdminPaymentsCubit(this.repository) : super(AdminPaymentsInitial());

  static AdminPaymentsCubit get(BuildContext context) => BlocProvider.of<AdminPaymentsCubit>(context);

  List<PaymentModel> paymentsList = [];
  int currentPage = 1;
  int lastPage = 1;
  String currentFilter = 'all';
  String currentSearch = '';
  bool hasMoreData = true;

  Future<void> getPayments({
    bool loadMore = false,
    String? filter,
    String? search,
  }) async {
    if (loadMore) {
      if (!hasMoreData) return;
      currentPage++;
    } else {
      currentPage = 1;
      paymentsList.clear();
      hasMoreData = true;
      if (filter != null) currentFilter = filter;
      if (search != null) currentSearch = search;
    }

    emit(GetAdminPaymentsLoadingState());

    final result = await repository.getPayments(
      page: currentPage,
      filter: currentFilter,
      search: currentSearch,
    );

    result.fold(
      (failureMessage) {
        emit(GetAdminPaymentsErrorState(failureMessage));
      },
      (data) {
        final List<PaymentModel> newPayments = data['payments'];
        lastPage = data['lastPage'];
        
        if (newPayments.isEmpty || currentPage >= lastPage) {
          hasMoreData = false;
        }

        if (loadMore) {
          paymentsList.addAll(newPayments);
        } else {
          paymentsList = newPayments;
        }

        emit(GetAdminPaymentsSuccessState());
      },
    );
  }

  void approvePayment(int paymentId) async {
    emit(AdminPaymentActionLoadingState());
    
    final result = await repository.approvePayment(paymentId);
    
    result.fold(
      (failureMessage) {
        emit(AdminPaymentActionErrorState(failureMessage));
      },
      (message) {
        // Find and update the payment status locally
        final index = paymentsList.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          final p = paymentsList[index];
          paymentsList[index] = PaymentModel(
            id: p.id,
            orderId: p.orderId,
            paymentMethod: p.paymentMethod,
            amount: p.amount,
            currency: p.currency,
            status: 'paid',
            gateway: p.gateway,
            moyasarPaymentId: p.moyasarPaymentId,
            paidAt: p.paidAt,
            verifiedAt: p.verifiedAt,
            receiptPath: p.receiptPath,
            receiptUrl: p.receiptUrl,
            createdAt: p.createdAt,
            order: p.order,
            user: p.user,
          );
        }
        emit(AdminPaymentActionSuccessState(message));
      },
    );
  }

  void rejectPayment(int paymentId) async {
    emit(AdminPaymentActionLoadingState());
    
    final result = await repository.rejectPayment(paymentId);
    
    result.fold(
      (failureMessage) {
        emit(AdminPaymentActionErrorState(failureMessage));
      },
      (message) {
        // Find and update the payment status locally
        final index = paymentsList.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          final p = paymentsList[index];
          paymentsList[index] = PaymentModel(
            id: p.id,
            orderId: p.orderId,
            paymentMethod: p.paymentMethod,
            amount: p.amount,
            currency: p.currency,
            status: 'rejected',
            gateway: p.gateway,
            moyasarPaymentId: p.moyasarPaymentId,
            paidAt: p.paidAt,
            verifiedAt: p.verifiedAt,
            receiptPath: p.receiptPath,
            receiptUrl: p.receiptUrl,
            createdAt: p.createdAt,
            order: p.order,
            user: p.user,
          );
        }
        emit(AdminPaymentActionSuccessState(message));
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/admin/payments/presentation/cubit/admin_payments_cubit.dart';
import 'package:moean/features/payment/data/models/payment_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPaymentsTableWidget extends StatelessWidget {
  final List<PaymentModel> payments;
  final ScrollController scrollController;

  const AdminPaymentsTableWidget({
    super.key,
    required this.payments,
    required this.scrollController,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      case 'pending':
      case 'processing':
      case 'waiting_verification':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getMethodText(String method) {
    if (method == 'manual_bank_transfer' || method == 'manual') {
      return appTranslation().get('payment_method_manual');
    } else if (method == 'moyasar') {
      return 'Moyasar';
    } else if (method == 'myfatoorah') {
      return 'MyFatoorah';
    }
    return method.isEmpty ? '-' : method;
  }

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: ColorsManager.primaryColor.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              appTranslation().get('no_payments_yet'),
              style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        controller: scrollController,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(ColorsManager.primaryColor.withValues(alpha: 0.1)),
          columns: [
            DataColumn(label: Text(appTranslation().get('admin_col_payment_id'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_col_user'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_col_service'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_col_method'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_col_amount'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_col_status'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_col_receipt'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_col_actions'), style: TextStylesManager.bold14)),
          ],
          rows: payments.map((payment) {
            final hasReceipt = payment.receiptUrl != null;
            final isManualProcessing = (payment.paymentMethod == 'manual_bank_transfer' || payment.paymentMethod == 'manual') && 
                                       payment.status == 'waiting_verification';
            
            return DataRow(
              cells: [
                DataCell(Text('#${payment.id}')),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(payment.user?.name ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(payment.user?.email ?? '-', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )),
                DataCell(Text(payment.order?.service?.name ?? '-')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (payment.paymentMethod == 'manual_bank_transfer' || payment.paymentMethod == 'manual')
                          const Icon(Icons.account_balance, size: 14, color: Colors.green),
                        if (payment.paymentMethod == 'myfatoorah' || payment.paymentMethod == 'moyasar')
                          const Icon(Icons.credit_card, size: 14, color: Colors.green),
                        if (payment.paymentMethod.isNotEmpty)
                          const SizedBox(width: 4),
                        Text(
                          _getMethodText(payment.paymentMethod),
                          style: const TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ),
                DataCell(Text('${payment.currency} ${payment.amount}', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          payment.status == 'paid' ? Icons.check_circle_outline : 
                          (payment.status == 'failed' || payment.status == 'rejected' ? Icons.error_outline : Icons.pending_outlined),
                          size: 14, 
                          color: _getStatusColor(payment.status)
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appTranslation().get('status_${payment.status}'),
                          style: TextStyle(color: _getStatusColor(payment.status), fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ),
                DataCell(
                  hasReceipt 
                    ? TextButton(
                        onPressed: () async {
                          final uri = Uri.parse(payment.receiptUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        child: Text(appTranslation().get('view'), style:  TextStyle(color: ColorsManager.primaryColor)),
                      )
                    : const Text('-')
                ),
                DataCell(
                  isManualProcessing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            tooltip: appTranslation().get('approve'),
                            onPressed: () {
                              AdminPaymentsCubit.get(context).approvePayment(payment.id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            tooltip: appTranslation().get('reject'),
                            onPressed: () {
                              AdminPaymentsCubit.get(context).rejectPayment(payment.id);
                            },
                          ),
                        ],
                      )
                    : Text(appTranslation().get('no_action'), style: const TextStyle(color: Colors.grey)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

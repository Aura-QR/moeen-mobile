import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';
import 'package:moean/features/payment/presentation/widgets/bank_info_widget.dart';
import 'package:moean/features/payment/presentation/widgets/order_summary_widget.dart';
import 'package:moean/features/payment/presentation/widgets/receipt_upload_widget.dart';

class BankTransferScreen extends StatefulWidget {
  const BankTransferScreen({super.key});

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  String? _filePath;
  String? _fileName;
  late int _orderId;
  late String _amount;
  late String _planName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, dynamic>?;
    _orderId = args?['orderId'] as int? ?? 0;
    _amount = args?['amount'] as String? ?? '';
    _planName = args?['planName'] as String? ?? '';
    PaymentCubit.get(context).loadBankInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.surfacePrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('pay_bank_transfer_title') ?? '',
          style: TextStylesManager.bold16.copyWith(
            color: ColorsManager.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorsManager.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: ColorsManager.borderColor),
        ),
      ),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listenWhen: (_, s) =>
            s is ReceiptUploaded || s is ReceiptUploadError,
        listener: (context, state) {
          if (state is ReceiptUploadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, textAlign: TextAlign.center),
                backgroundColor: ColorsManager.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is ReceiptUploaded) {
            Navigator.pushReplacementNamed(
              context,
              Routes.paymentResult,
              arguments: {
                'status': state.payment.status,
                'from': 'bank',
              },
            );
          }
        },
        buildWhen: (_, s) =>
            s is BankInfoLoading ||
            s is BankInfoLoaded ||
            s is BankInfoError ||
            s is ReceiptUploading,
        builder: (context, state) {
          final cubit = PaymentCubit.get(context);
          return ConditionalBuilder(
            loadingState: state is BankInfoLoading,
            errorState: state is BankInfoError,
            errorBuilder: (_) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  (state as BankInfoError).error,
                  style: TextStylesManager.regular14
                      .copyWith(color: ColorsManager.errorColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            successBuilder: (_) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_planName.isNotEmpty || _amount.isNotEmpty)
                    OrderSummaryWidget(
                      planName: _planName,
                      amount: _amount,
                    ),
                  verticalSpace16,
                  if (cubit.bankInfo != null)
                    BankInfoWidget(bankInfo: cubit.bankInfo!),
                  verticalSpace16,
                  _UploadSection(
                    onFileSelected: (path, name) {
                      _filePath = path;
                      _fileName = name;
                    },
                  ),
                  verticalSpace24,
                  PrimaryElevatedButton(
                    text: appTranslation().get('pay_send_receipt') ?? '',
                    icon: Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: ColorsManager.white,
                    ),
                    isLoading: state is ReceiptUploading,
                    onPressed: state is ReceiptUploading
                        ? null
                        : () {
                            if (_filePath == null || _fileName == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    appTranslation().get(
                                            'pay_please_choose_receipt') ??
                                        '',
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: ColorsManager.errorColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              return;
                            }
                            cubit.uploadReceiptForOrder(
                              orderId: _orderId,
                              filePath: _filePath!,
                              fileName: _fileName!,
                            );
                          },
                  ),
                  verticalSpace16,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UploadSection extends StatelessWidget {
  final void Function(String, String) onFileSelected;

  const _UploadSection({required this.onFileSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: ReceiptUploadWidget(onFileSelected: onFileSelected),
    );
  }
}

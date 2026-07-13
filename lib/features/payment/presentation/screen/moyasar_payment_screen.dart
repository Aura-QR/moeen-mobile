import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';
import 'package:moean/features/payment/presentation/widgets/moyasar_card_details_widget.dart';
import 'package:moean/features/payment/presentation/widgets/moyasar_card_name_widget.dart';
import 'package:moean/features/payment/presentation/widgets/moyasar_footer_widget.dart';
import 'package:moean/features/payment/presentation/widgets/moyasar_header_widget.dart';

class MoyasarPaymentScreen extends StatefulWidget {
  const MoyasarPaymentScreen({super.key});

  @override
  State<MoyasarPaymentScreen> createState() => _MoyasarPaymentScreenState();
}

class _MoyasarPaymentScreenState extends State<MoyasarPaymentScreen> {
  late String _amount;
  late int _orderId;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _amount = args?['amount'] as String? ?? '0';
    _orderId = args?['orderId'] as int? ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      PaymentCubit.get(context).getMoyasarConfig(_orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listenWhen: (_, s) =>
          s is MoyasarConfigLoaded ||
          s is MoyasarConfigError ||
          s is PaymentVerified ||
          s is PaymentVerifyError,
      listener: (context, state) {
        if (state is MoyasarConfigError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: ColorsManager.errorColor,
            ),
          );
        } else if (state is MoyasarConfigLoaded) {
          _handleMoyasarSuccess(state.config);
        } else if (state is PaymentVerified) {
          Navigator.pushReplacementNamed(
            context,
            Routes.paymentResult,
            arguments: {'status': state.payment.status, 'from': 'moyasar'},
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.surfacePrimary,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ColorsManager.textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const MoyasarHeaderWidget(),
                    verticalSpace24,
                    MoyasarCardNameWidget(controller: _nameController),
                    verticalSpace20,
                    MoyasarCardDetailsWidget(
                      numberController: _numberController,
                      expiryController: _expiryController,
                      cvcController: _cvcController,
                    ),
                    verticalSpace32,
                    PrimaryElevatedButton(
                      text: '$_amount ${appTranslation().get('currency_sar')}',
                      isLoading: state is MoyasarConfigLoading || state is PaymentVerifying,
                      onPressed: _processPayment,
                      backgroundColor: const Color(0xFF1B49A8), // matching button in image
                    ),
                    verticalSpace24,
                    const MoyasarFooterWidget(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMoyasarSuccess(Map<String, dynamic> config) async {
    const mockPaymentId = "pay_123456789";
    if (mounted) {
      PaymentCubit.get(context).verifyPayment(mockPaymentId, orderId: _orderId);
    }
  }
}

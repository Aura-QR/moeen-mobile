import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';
import 'package:moean/features/payment/presentation/widgets/visa_card_display.dart';
import 'package:moean/core/utils/constants/secrets.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

class MyfatoorahPaymentScreen extends StatefulWidget {
  const MyfatoorahPaymentScreen({super.key});

  @override
  State<MyfatoorahPaymentScreen> createState() => _MyfatoorahPaymentScreenState();
}

class _MyfatoorahPaymentScreenState extends State<MyfatoorahPaymentScreen> {
  late String _amount;
  late int _orderId;
  String? _sessionId;
  
  late MFCardPaymentView mfCardView;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    MFSDK.init(Secrets.myfatoorahApiKey, MFCountry.SAUDIARABIA, MFEnvironment.LIVE);
    
    // تصميم حقول MyFatoorah المدمجة بأفضل شكل ممكن
    MFCardViewStyle cardViewStyle = MFCardViewStyle();
    cardViewStyle.cardHeight = 300;
    cardViewStyle.hideCardIcons = false;
    
    // ستايل الحقول
    cardViewStyle.input?.inputMargin = 12;
    
    // ستايل العناوين
    cardViewStyle.label?.display = true;
    cardViewStyle.label?.fontWeight = MFFontWeight.Bold;
    
    mfCardView = MFCardPaymentView(cardViewStyle: cardViewStyle);
  }
  
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _amount = args?['amount'] as String? ?? '0';
      _orderId = args?['orderId'] as int? ?? 0;
      
      PaymentCubit.get(context).initMyfatoorahPayment(_orderId);
    }
  }

  void _setupMyfatoorahSDK(String sessionId, String portalHost) {
    _sessionId = sessionId;
    final initiateSessionResponse = MFInitiateSessionResponse(
      sessionId: sessionId,
      countryCode: MFCountry.SAUDIARABIA,
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        mfCardView.load(initiateSessionResponse, null);
      }
    });
  }

  void _executePayment() {
    if (_sessionId != null) {
       setState(() { _isProcessing = true; });
       final invoiceAmount = double.tryParse(_amount) ?? 0.0;
       final executeRequest = MFExecutePaymentRequest(
          invoiceValue: invoiceAmount,
          sessionId: _sessionId,
       );
       
       mfCardView.pay(executeRequest, MFLanguage.ARABIC, (String invoiceId) {
          // Callback
       }).then((response) {
          if (!mounted) return;
          setState(() { _isProcessing = false; });
          if (response.invoiceStatus == "Paid") {
             final paymentKey = (response.invoiceTransactions != null && response.invoiceTransactions!.isNotEmpty)
                 ? (response.invoiceTransactions!.first.paymentId ?? response.invoiceId?.toString() ?? "")
                 : (response.invoiceId?.toString() ?? "");
             PaymentCubit.get(context).verifyMyfatoorahPayment(paymentKey);
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("فشلت عملية الدفع")),
             );
          }
       }).catchError((error) {
          if (!mounted) return;
          setState(() { _isProcessing = false; });
          String errorMsg = error.toString();
          if (error is MFError) {
             errorMsg = error.message ?? errorMsg;
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
       });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listenWhen: (_, s) =>
          s is MyfatoorahSessionLoaded ||
          s is MyfatoorahSessionError ||
          s is MyfatoorahExecuteLoaded ||
          s is MyfatoorahExecuteError ||
          s is PaymentVerified ||
          s is PaymentVerifyError,
      listener: (context, state) {
        if (state is MyfatoorahSessionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: ColorsManager.errorColor),
          );
        } else if (state is PaymentVerifyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: ColorsManager.errorColor),
          );
        } else if (state is MyfatoorahSessionLoaded) {
          final session = state.session['session'];
          if (session != null) {
             setState(() {
                if (session['amount'] != null) {
                  _amount = session['amount'].toString();
                }
                if (session['order_id'] != null) {
                  _orderId = session['order_id'] is int 
                      ? session['order_id'] as int 
                      : (int.tryParse(session['order_id'].toString()) ?? _orderId);
                }
                _setupMyfatoorahSDK(session['session_id'], session['portal_host']);
             });
          }
        } else if (state is PaymentVerified) {
          Navigator.pushReplacementNamed(
            context,
            Routes.paymentResult,
            arguments: {'status': state.payment.status, 'from': 'myfatoorah'},
          );
        }
      },
      builder: (context, state) {
        final isLoadingSession = state is MyfatoorahSessionLoading;
        final isExecuting = state is MyfatoorahExecuteLoading || state is PaymentVerifying;
        final isError = state is MyfatoorahSessionError;

        return Scaffold(
          backgroundColor: ColorsManager.background,
          appBar: AppBar(
            backgroundColor: ColorsManager.surfacePrimary,
            elevation: 0,
            title: Text(
              appTranslation().get('electronic_payment'),
              style: TextStyle(color: ColorsManager.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: ColorsManager.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const VisaCardDisplay(
                    cardNumber: '',
                    cardHolder: '',
                    expiryDate: '',
                  ),
                  verticalSpace24,
                  ConditionalBuilder(
                    loadingState: isLoadingSession,
                    errorState: isError,
                    errorBuilder: (context) {
                      final errorMsg = state is MyfatoorahSessionError ? state.error : '';
                      return Column(
                        children: [
                          Text('${appTranslation().get('session_error')}$errorMsg', style: const TextStyle(color: Colors.red)),
                          verticalSpace16,
                          PrimaryElevatedButton(
                            text: appTranslation().get('retry'),
                            onPressed: () => PaymentCubit.get(context).initMyfatoorahPayment(_orderId),
                          ),
                        ]
                      );
                    },
                    successBuilder: (context) {
                      if (_sessionId == null) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            appTranslation().get('card_details'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          verticalSpace16,
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              height: 300,
                              child: mfCardView,
                            ),
                          ),
                          
                          verticalSpace32,
                          PrimaryElevatedButton(
                            text: '${appTranslation().get('pay_btn_prefix')} $_amount ${appTranslation().get('currency_sar')}',
                            isLoading: _isProcessing || isExecuting,
                            onPressed: _executePayment,
                            backgroundColor: const Color(0xFF1B49A8), 
                          ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

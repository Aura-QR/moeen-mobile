import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';

class MoyasarPaymentScreen extends StatefulWidget {
  const MoyasarPaymentScreen({super.key});

  @override
  State<MoyasarPaymentScreen> createState() => _MoyasarPaymentScreenState();
}

class _MoyasarPaymentScreenState extends State<MoyasarPaymentScreen> {
  late String _amount;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _amount = args?['amount'] as String? ?? '0';
  }

  void _processPayment() async {
    setState(() => _isLoading = true);
    // Simulate network delay for payment processing
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    // Navigate to result screen
    Navigator.pushReplacementNamed(
      context,
      Routes.paymentResult,
      arguments: {
        'status': 'paid', // Show success for demonstration
        'from': 'moyasar',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: ColorsManager.borderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _HeaderSection(),
            verticalSpace32,
            _CardFormSection(),
            verticalSpace32,
            PrimaryElevatedButton(
              text: '$_amount ر.س',
              textStyle: TextStylesManager.bold16.copyWith(
                color: ColorsManager.white,
              ),
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _processPayment,
            ),
            verticalSpace24,
            _FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              appTranslation().get('pay_online_title') ?? '',
              style: TextStylesManager.bold22.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
            verticalSpace4,
            Text(
              appTranslation().get('pay_online_subtitle') ?? '',
              style: TextStylesManager.regular14.copyWith(
                color: ColorsManager.secondaryText,
              ),
            ),
          ],
        ),
        horizontalSpace16,
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.credit_card_outlined,
            color: Color(0xFF1B5E20),
            size: 28,
          ),
        ),
      ],
    );
  }
}

class _CardFormSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          appTranslation().get('pay_name_on_card') ?? '',
          style: TextStylesManager.bold14.copyWith(
            color: ColorsManager.textPrimary,
          ),
        ),
        verticalSpace8,
        _CustomTextField(
          hintText: appTranslation().get('pay_name_on_card') ?? '',
        ),
        verticalSpace24,
        Text(
          appTranslation().get('pay_card_info') ?? '',
          style: TextStylesManager.bold14.copyWith(
            color: ColorsManager.textPrimary,
          ),
        ),
        verticalSpace8,
        Container(
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorsManager.borderColor),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _CardBrandLogos(),
                    horizontalSpace16,
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        style: TextStylesManager.regular14.copyWith(
                          color: ColorsManager.textPrimary,
                          letterSpacing: 2,
                        ),
                        decoration: InputDecoration(
                          hintText: '1234 5678 9101 1121',
                          hintStyle: TextStylesManager.regular14.copyWith(
                            color: ColorsManager.secondaryText,
                            letterSpacing: 2,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: ColorsManager.borderColor),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.number,
                          style: TextStylesManager.regular14.copyWith(
                            color: ColorsManager.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: appTranslation().get('pay_expiry_date') ?? '',
                            hintStyle: TextStylesManager.regular14.copyWith(
                              color: ColorsManager.secondaryText,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(width: 1, color: ColorsManager.borderColor),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          textAlign: TextAlign.end,
                          keyboardType: TextInputType.number,
                          style: TextStylesManager.regular14.copyWith(
                            color: ColorsManager.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: appTranslation().get('pay_cvc') ?? '',
                            hintStyle: TextStylesManager.regular14.copyWith(
                              color: ColorsManager.secondaryText,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardBrandLogos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Badge(text: 'VISA', color: const Color(0xFF1A1F71)),
        horizontalSpace4,
        _Badge(text: 'MC', color: const Color(0xFFEB001B)),
        horizontalSpace4,
        _Badge(text: 'mada', color: const Color(0xFF00BFA5)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;

  const _CustomTextField({required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.end,
      style: TextStylesManager.regular14.copyWith(
        color: ColorsManager.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStylesManager.regular14.copyWith(
          color: ColorsManager.secondaryText,
        ),
        filled: true,
        fillColor: ColorsManager.surfacePrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorsManager.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorsManager.primaryColor, width: 1.5),
        ),
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          appTranslation().get('pay_service_provided_by') ?? '',
          style: TextStylesManager.regular12.copyWith(
            color: ColorsManager.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        verticalSpace8,
        Text(
          appTranslation().get('pay_test_mode_warning') ?? '',
          style: TextStylesManager.regular12.copyWith(
            color: ColorsManager.errorColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

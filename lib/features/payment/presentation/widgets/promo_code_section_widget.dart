import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';

class PromoCodeSectionWidget extends StatefulWidget {
  const PromoCodeSectionWidget({super.key});

  @override
  State<PromoCodeSectionWidget> createState() => _PromoCodeSectionWidgetState();
}

class _PromoCodeSectionWidgetState extends State<PromoCodeSectionWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _applyPromo(BuildContext context) {
    final cubit = PaymentCubit.get(context);
    cubit.validatePromo(_controller.text);
  }

  void _clearPromo(BuildContext context) {
    _controller.clear();
    PaymentCubit.get(context).clearPromo();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      buildWhen: (_, s) =>
          s is PromoValidating ||
          s is PromoValidated ||
          s is PromoError ||
          s is PromoCleared,
      builder: (context, state) {
        final cubit = PaymentCubit.get(context);
        final isValidated = state is PromoValidated ||
            (cubit.promoValidation != null && state is! PromoCleared);
        final isLoading = state is PromoValidating;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsManager.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appTranslation().get('promo_section_title'),
                style: TextStylesManager.bold16
                    .copyWith(color: ColorsManager.textPrimary),
              ),
              verticalSpace12,
              // Input row
              Row(
                children: [
                  // Apply / Remove button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isValidated
                        ? GestureDetector(
                            key: const ValueKey('remove'),
                            onTap: () => _clearPromo(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: ColorsManager.errorColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: ColorsManager.errorColor
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                appTranslation().get('promo_remove'),
                                style: TextStylesManager.medium14.copyWith(
                                    color: ColorsManager.errorColor),
                              ),
                            ),
                          )
                        : GestureDetector(
                            key: const ValueKey('apply'),
                            onTap: isLoading ? null : () => _applyPromo(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: ColorsManager.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      appTranslation().get('promo_apply'),
                                      style: TextStylesManager.medium14
                                          .copyWith(color: Colors.white),
                                    ),
                            ),
                          ),
                  ),
                  horizontalSpace10,
                  // Text field
                  Expanded(
                    child: PrimaryTextField(
                      controller: _controller,
                      hint: appTranslation().get('promo_hint'),
                      enabled: !isValidated && !isLoading,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _applyPromo(context),
                    ),
                  ),
                ],
              ),
              // Feedback row
              if (state is PromoValidated) ...[
                verticalSpace10,
                _PromoSuccessBanner(data: state.data),
              ] else if (state is PromoError) ...[
                verticalSpace10,
                _PromoErrorBanner(message: state.error),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PromoSuccessBanner extends StatelessWidget {
  final Map<String, dynamic> data;

  const _PromoSuccessBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    final discount = data['discount'] as Map<String, dynamic>?;
    final discountType = discount?['type'] as String? ?? 'percentage';
    final discountValue = (discount?['value'] as num?)?.toDouble() ?? 0.0;
    final finalAmount = (data['final_amount'] as num?)?.toDouble();

    final discountDisplay = discountType == 'percentage'
        ? '${discountValue.toStringAsFixed(0)}%'
        : '${discountValue.toStringAsFixed(2)} ر.س';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (finalAmount != null)
            Text(
              '$finalAmount ر.س',
              style: TextStylesManager.bold14
                  .copyWith(color: const Color(0xFF16A34A)),
            ),
          const Spacer(),
          Text(
            '${appTranslation().get('promo_discount_label')}: $discountDisplay',
            style: TextStylesManager.medium14
                .copyWith(color: const Color(0xFF16A34A)),
          ),
          horizontalSpace8,
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF22C55E), size: 18),
        ],
      ),
    );
  }
}

class _PromoErrorBanner extends StatelessWidget {
  final String message;

  const _PromoErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorsManager.errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: ColorsManager.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: ColorsManager.errorColor, size: 18),
          horizontalSpace8,
          Expanded(
            child: Text(
              message,
              style: TextStylesManager.regular13
                  .copyWith(color: ColorsManager.errorColor),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

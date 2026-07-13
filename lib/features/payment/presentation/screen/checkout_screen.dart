import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';
import 'package:moean/features/payment/presentation/widgets/plan_card_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    PaymentCubit.get(context).loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      body: SafeArea(
        child: Column(
          children: [
            _CheckoutHeader(),
            Expanded(
              child: BlocConsumer<PaymentCubit, PaymentState>(
                listenWhen: (_, s) =>
                    s is OrderCreated || s is OrderError,
                listener: (context, state) {
                  if (state is OrderError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error, textAlign: TextAlign.center),
                        backgroundColor: ColorsManager.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  } else if (state is OrderCreated) {
                    final cubit = PaymentCubit.get(context);
                    if (cubit.selectedMethodIndex == 0) {
                      context.push<Map<String, dynamic>>(
                        Routes.moyasarPayment,
                        arguments: {
                          'orderId': state.order.id,
                          'amount': state.order.amount,
                        },
                      );
                    } else {
                      context.push<Map<String, dynamic>>(
                        Routes.bankTransfer,
                        arguments: {
                          'orderId': state.order.id,
                          'amount': state.order.amount,
                          'planName': state.order.service?.name ?? '',
                        },
                      );
                    }
                  }
                },
                buildWhen: (_, s) =>
                    s is PlansLoading ||
                    s is PlansLoaded ||
                    s is PlansError ||
                    s is OrderCreating,
                builder: (context, state) {
                  final cubit = PaymentCubit.get(context);
                  return ConditionalBuilder(
                    loadingState: state is PlansLoading,
                    errorState: state is PlansError,
                    emptyState: state is PlansLoaded && cubit.plans.isEmpty,
                    errorBuilder: (_) => Center(
                      child: Text(
                        (state as PlansError).error,
                        style: TextStylesManager.regular14.copyWith(
                            color: ColorsManager.errorColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    emptyBuilder: (_) => Center(
                      child: Text(
                        appTranslation().get('pay_no_plans') ?? '',
                        style: TextStylesManager.regular14,
                      ),
                    ),
                    successBuilder: (_) =>
                        _CheckoutBody(isSubmitting: state is OrderCreating),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
       // crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            appTranslation().get('pay_subscription_label') ?? '',
            style: TextStylesManager.regular12.copyWith(
              color: ColorsManager.secondaryText,
            ),
          ),
          verticalSpace4,
          Text(
            appTranslation().get('pay_checkout_title') ?? '',
            style: TextStylesManager.bold22.copyWith(
              color: ColorsManager.textPrimary,
            ),
          ),
         ],
      ),
    );
  }
}


class _CheckoutBody extends StatelessWidget {
  final bool isSubmitting;

  const _CheckoutBody({required this.isSubmitting});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      buildWhen: (_, s) =>
          s is PlansLoaded || s is OrderCreating || s is OrderCreated || s is OrderError,
      builder: (context, state) {
        final cubit = PaymentCubit.get(context);
        final plans = cubit.plans;
        final selectedPlan = plans.isNotEmpty ? plans[cubit.selectedPlanIndex] : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SectionCard(
                title: appTranslation().get('pay_plan_label') ?? '',
                child: Column(
                  children: List.generate(
                    plans.length,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: i < plans.length - 1 ? 10 : 0),
                      child: PlanCardWidget(
                        plan: plans[i],
                        isSelected: cubit.selectedPlanIndex == i,
                        onTap: () => cubit.selectPlan(i),
                      ),
                    ),
                  ),
                ),
              ),
              verticalSpace16,
              _SectionCard(
                title: appTranslation().get('pay_method_label') ?? '',
                child: Column(
                  children: [
                    _PaymentMethodTile(
                      icon: Icons.credit_card_outlined,
                      title: appTranslation().get('pay_method_online') ?? '',
                      subtitle: 'Moyasar - ${appTranslation().get('pay_method_online_subtitle') ?? ''}',
                      isSelected: cubit.selectedMethodIndex == 0,
                      onTap: () => cubit.selectMethod(0),
                    ),
                    verticalSpace10,
                    _PaymentMethodTile(
                      icon: Icons.account_balance_outlined,
                      title: appTranslation().get('pay_method_bank') ?? '',
                      subtitle: appTranslation().get('pay_method_bank_subtitle') ?? '',
                      isSelected: cubit.selectedMethodIndex == 1,
                      onTap: () => cubit.selectMethod(1),
                    ),
                  ],
                ),
              ),
              if (selectedPlan != null) ...[
                verticalSpace16,
                _SectionCard(
                  title: appTranslation().get('pay_order_summary') ?? '',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F0E0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${selectedPlan.price} ر.س',
                              style: TextStylesManager.bold14.copyWith(
                                  color: const Color(0xFF8B6914)),
                            ),
                          ),
                          Text(
                            selectedPlan.name,
                            style: TextStylesManager.bold16.copyWith(
                                color: ColorsManager.textPrimary),
                          ),
                        ],
                      ),
                      verticalSpace10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.verified_outlined,
                              size: 15, color: ColorsManager.primaryColor),
                          horizontalSpace6,
                          Flexible(
                            child: Text(
                              appTranslation().get('pay_server_amount_note') ?? '',
                              style: TextStylesManager.regular12.copyWith(
                                  color: ColorsManager.secondaryText),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              verticalSpace24,
              PrimaryElevatedButton(
                text: cubit.selectedMethodIndex == 0
                    ? (appTranslation().get('pay_proceed_online') ?? '')
                    : (appTranslation().get('pay_proceed_bank') ?? ''),
                icon: Icon(
                  cubit.selectedMethodIndex == 0
                      ? Icons.credit_card_outlined
                      : Icons.account_balance_outlined,
                  size: 20,
                  color: ColorsManager.white,
                ),
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : () => cubit.createOrder(),
              ),
              verticalSpace16,
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStylesManager.bold16.copyWith(
                color: ColorsManager.textPrimary),
          ),
          verticalSpace12,
          child,
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? ColorsManager.primaryColor
                      : ColorsManager.borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsManager.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            horizontalSpace12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title,
                      style: TextStylesManager.medium14
                          .copyWith(color: ColorsManager.textPrimary)),
                  verticalSpace2,
                  Text(subtitle,
                      style: TextStylesManager.regular12
                          .copyWith(color: ColorsManager.secondaryText)),
                ],
              ),
            ),
            horizontalSpace10,
            Icon(icon,
                size: 20,
                color: isSelected
                    ? ColorsManager.primaryColor
                    : ColorsManager.secondaryText),
          ],
        ),
      ),
    );
  }
}

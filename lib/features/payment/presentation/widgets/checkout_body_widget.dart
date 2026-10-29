import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';
import 'package:moean/features/payment/presentation/widgets/checkout_section_card_widget.dart';
import 'package:moean/features/payment/presentation/widgets/order_summary_widget.dart';
import 'package:moean/features/payment/presentation/widgets/payment_method_tile_widget.dart';
import 'package:moean/features/payment/presentation/widgets/plan_card_widget.dart';
import 'package:moean/features/payment/presentation/widgets/promo_code_section_widget.dart';
import 'package:moean/features/payment/presentation/widgets/subscription_terms_widget.dart';
import 'package:moean/features/payment/presentation/widgets/subscription_usage_limits_widget.dart';

class CheckoutBodyWidget extends StatelessWidget {
  final bool isSubmitting;

  const CheckoutBodyWidget({
    super.key,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      buildWhen: (_, s) =>
          s is PlansLoaded ||
          s is OrderCreating ||
          s is OrderCreated ||
          s is OrderError,
      builder: (context, state) {
        final cubit = PaymentCubit.get(context);
        final plans = cubit.plans;
        final selectedPlan =
            plans.isNotEmpty ? plans[cubit.selectedPlanIndex] : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckoutSectionCardWidget(
                title: appTranslation().get('pay_plan_label'),
                child: Column(
                  children: List.generate(
                    plans.length,
                    (i) => Padding(
                      padding: EdgeInsets.only(
                        bottom: i < plans.length - 1 ? 10 : 0,
                      ),
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
              const SubscriptionTermsWidget(),
              verticalSpace16,
              const SubscriptionUsageLimitsWidget(),
              verticalSpace16,
              const PromoCodeSectionWidget(),
              verticalSpace16,
              CheckoutSectionCardWidget(
                title: appTranslation().get('pay_method_label'),
                child: Column(
                  children: [
                    PaymentMethodTileWidget(
                      icon: Icons.credit_card_outlined,
                      title: appTranslation().get('pay_method_online'),
                      subtitle:
                          'MyFatoorah - ${appTranslation().get('pay_method_online_subtitle')}',
                      isSelected: cubit.selectedMethodIndex == 0,
                      onTap: () => cubit.selectMethod(0),
                    ),
                  ],
                ),
              ),
              if (selectedPlan != null) ...[
                verticalSpace16,
                OrderSummaryWidget(
                  planName: selectedPlan.name,
                  amount: selectedPlan.price,
                ),
              ],
              verticalSpace24,
              PrimaryElevatedButton(
                text: cubit.selectedMethodIndex == 0
                    ? appTranslation().get('pay_proceed_online')
                    : appTranslation().get('pay_proceed_bank'),
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

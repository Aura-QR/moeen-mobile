import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/payment_state.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_state.dart';
import 'package:moean/features/payment/presentation/widgets/active_subscription_card_widget.dart';
import 'package:moean/features/payment/presentation/widgets/checkout_body_widget.dart';
import 'package:moean/features/profile/presentation/cubit/profile_cubit.dart';

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
    sl<SubscriptionCubit>().fetchCurrentSubscription(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('payment'),
          style: TextStylesManager.bold18.copyWith(
            color: ColorsManager.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<PaymentCubit, PaymentState>(
                listenWhen: (_, s) =>
                    s is OrderCreated ||
                    s is OrderError ||
                    s is PaymentAlreadySubscribed ||
                    s is PaymentCheckoutInProgress,
                listener: (context, state) {
                  if (state is OrderError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error, textAlign: TextAlign.center),
                        backgroundColor: ColorsManager.errorColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  } else if (state is PaymentAlreadySubscribed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.details['message']?.toString() ??
                              appTranslation().get('pay_active_sub_already_msg'),
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: ColorsManager.primaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    sl<ProfileCubit>().fetchProfile(forceRefresh: true);
                    sl<SubscriptionCubit>().fetchCurrentSubscription(forceRefresh: true);
                  } else if (state is PaymentCheckoutInProgress) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.details['message']?.toString() ??
                              appTranslation().get('pay_in_progress_msg'),
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: ColorsManager.secondaryColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    final details = state.details['details'];
                    if (details != null && details['order'] != null) {
                      context.push<Map<String, dynamic>>(
                        Routes.myfatoorahPayment,
                        arguments: {
                          'orderId': details['order']['id'],
                          'amount': details['order']['amount'],
                        },
                      );
                    }
                  } else if (state is OrderCreated) {
                    final cubit = PaymentCubit.get(context);
                    if (cubit.selectedMethodIndex == 0) {
                      context.push<Map<String, dynamic>>(
                        Routes.myfatoorahPayment,
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
                    s is OrderCreating ||
                    s is OrderCreated ||
                    s is OrderError ||
                    s is PromoValidating ||
                    s is PromoValidated ||
                    s is PromoError ||
                    s is PromoCleared,
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
                          color: ColorsManager.errorColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    emptyBuilder: (_) => Center(
                      child: Text(
                        appTranslation().get('pay_no_plans'),
                        style: TextStylesManager.regular14,
                      ),
                    ),
                    successBuilder: (_) {
                      return BlocBuilder<SubscriptionCubit, SubscriptionState>(
                        bloc: sl<SubscriptionCubit>(),
                        builder: (context, subState) {
                          if (subState is SubscriptionLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final currentSub =
                              sl<SubscriptionCubit>().currentSubscription;
                          if (currentSub != null &&
                              currentSub.isSubscribed &&
                              !currentSub.isSubscriptionExpired) {
                            return ActiveSubscriptionCardWidget(
                              subscription: currentSub,
                            );
                          }
                          return CheckoutBodyWidget(
                            isSubmitting: state is OrderCreating,
                          );
                        },
                      );
                    },
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_state.dart';

class TrialBannerWidget extends StatefulWidget {
  const TrialBannerWidget({super.key});

  static bool isBannerVisible(SubscriptionState state) {
    if (state is SubscriptionLoaded) {
      final current = state.current;
      if (current.isSubscribed && !current.isSubscriptionExpired) {
        return false;
      }
      return true;
    } else if (state is SubscriptionError) {
      if (state.error.contains('__402__') ||
          state.error.contains('trial_expired') ||
          state.error.contains('انتهت')) {
        return true;
      }
    } else {
      final current = sl<SubscriptionCubit>().currentSubscription;
      if (current != null) {
        if (current.isSubscribed && !current.isSubscriptionExpired) {
          return false;
        }
        return true;
      }
    }
    return false;
  }

  @override
  State<TrialBannerWidget> createState() => _TrialBannerWidgetState();
}

class _TrialBannerWidgetState extends State<TrialBannerWidget> {
  @override
  void initState() {
    super.initState();
    final cubit = sl<SubscriptionCubit>();
    if (cubit.currentSubscription == null && cubit.lastError == null && cubit.state is SubscriptionInitial) {
      cubit.fetchCurrentSubscription();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      bloc: sl<SubscriptionCubit>(),
      builder: (context, state) {
        if (state is SubscriptionLoaded) {
          final current = state.current;
          
          if (current.isSubscribed && !current.isSubscriptionExpired) {
            // Subscribed and Active -> Hidden
            return const SizedBox.shrink();
          }

          if (current.isSubscribed && current.isSubscriptionExpired) {
            // Subscribed but expired
            return _buildBanner(
              context,
              icon: Icons.alarm,
              text: '⏰ انتهى اشتراكك المدفوع.',
              buttonText: 'جدد اشتراكك',
              color: ColorsManager.errorColor,
              isExpired: true,
            );
          }

          if (current.isInTrial) {
            final days = current.dynamicDaysRemaining;
            if (days <= 0) {
              // Trial expired
              return _buildBanner(
                context,
                icon: Icons.alarm,
                text: '⏰ انتهت فترتك التجريبية المجانية.',
                buttonText: 'اشترك الآن',
                color: ColorsManager.errorColor,
                isExpired: true,
              );
            } else if (days == 1) {
              return _buildBanner(
                context,
                icon: Icons.warning_amber_rounded,
                text: '⚠️ آخر يوم في تجربتك المجانية!',
                buttonText: 'اشترك الآن',
                color: ColorsManager.errorColor,
                isExpired: false,
              );
            } else {
              return _buildBanner(
                context,
                icon: Icons.celebration,
                text: '🎉 متبقي $days أيام على التجربة المجانية',
                buttonText: 'اشترك الآن',
                color: ColorsManager.errorColor,
                isExpired: false,
              );
            }
          }

          // Not in trial and not subscribed -> Trial Expired
          return _buildBanner(
            context,
            icon: Icons.alarm,
            text: '⏰ انتهت فترتك التجريبية المجانية.',
            buttonText: 'اشترك الآن',
            color: ColorsManager.errorColor,
            isExpired: true,
          );
        } else if (state is SubscriptionError) {
          if (state.error.contains('__402__') ||
              state.error.contains('trial_expired') ||
              state.error.contains('انتهت')) {
            return _buildBanner(
              context,
              icon: Icons.alarm,
              text: '⏰ انتهت فترتك التجريبية المجانية.',
              buttonText: 'اشترك الآن',
              color: ColorsManager.errorColor,
              isExpired: true,
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner(BuildContext context, {
    required IconData icon,
    required String text,
    required String buttonText,
    required Color color,
    required bool isExpired,
  }) {
    return Container(
      width: double.infinity,
      color: color,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStylesManager.bold13.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.checkout);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStylesManager.bold12,
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}

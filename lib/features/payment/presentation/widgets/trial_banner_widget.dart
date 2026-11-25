import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_state.dart';
import 'package:moean/features/payment/presentation/widgets/trial_banner_bar_widget.dart';
import 'package:moean/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:moean/features/profile/presentation/cubit/profile_state.dart';

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
    // Always force-refresh to pick up payment status changes immediately
    sl<SubscriptionCubit>().fetchCurrentSubscription(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      bloc: sl<SubscriptionCubit>(),
      builder: (context, subState) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          bloc: sl<ProfileCubit>(),
          builder: (context, profileState) {
            final state = subState;
            if (state is SubscriptionLoaded) {
              final current = state.current;
              
              if (current.isSubscribed && !current.isSubscriptionExpired) {
                // Subscribed and Active -> Hidden
                return const SizedBox.shrink();
              }

              if (current.isSubscribed && current.isSubscriptionExpired) {
                // Subscribed but expired
                return TrialBannerBarWidget(
                  text: '⏰ انتهى اشتراكك المدفوع.',
                  color: ColorsManager.errorColor,
                );
              }

              if (current.isInTrial) {
                final days = current.dynamicDaysRemaining;
                if (days <= 0) {
                  // Trial expired
                  return TrialBannerBarWidget(
                    text: '⏰ انتهت فترتك التجريبية المجانية.',
                    color: ColorsManager.errorColor,
                  );
                } else if (days == 1) {
                  return TrialBannerBarWidget(
                    text: '⚠️ آخر يوم في تجربتك المجانية!',
                    color: ColorsManager.errorColor,
                  );
                } else {
                  return TrialBannerBarWidget(
                    text: '🎉 متبقي $days أيام على التجربة المجانية',
                    color:const Color(0xFFD97706),
                    // ColorsManager.primaryColor,
                  );
                }
              }

              // Not in trial and not subscribed -> Trial Expired
              return TrialBannerBarWidget(
                text: '⏰ انتهت فترتك التجريبية المجانية.',
                color: ColorsManager.errorColor,
              );
            } else if (state is SubscriptionError) {
              // Fallback check on ProfileCubit state
              final teacher = sl<ProfileCubit>().profileModel?.teacher;
              if (teacher != null && teacher.isSubscribed) {
                return const SizedBox.shrink();
              }
              
              if (state.error.contains('__402__') ||
                  state.error.contains('trial_expired') ||
                  state.error.contains('انتهت')) {
                return TrialBannerBarWidget(
                  text: '⏰ انتهت فترتك التجريبية المجانية.',
                  color: ColorsManager.errorColor,
                );
              }
            } else {
              // If not loaded and no error, fallback to profile
              final teacher = sl<ProfileCubit>().profileModel?.teacher;
              if (teacher != null && teacher.isSubscribed) {
                return const SizedBox.shrink();
              }
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

}

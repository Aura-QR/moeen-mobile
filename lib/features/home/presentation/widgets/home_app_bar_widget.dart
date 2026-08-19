import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/home/presentation/cubit/home_cubit.dart';
import 'package:moean/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:moean/features/profile/presentation/cubit/profile_state.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_cubit.dart';
import 'package:moean/features/payment/presentation/widgets/subscription_status_dialog.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final bool isAdmin = context.read<HomeCubit>().isAdmin;
        final bool isLoggedIn = token != null && token!.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    AssetsHelper.logo,
                    width: 45,
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              if (isLoggedIn)
                Row(
                  children: [
                    // Phone icon button — contact (Hidden for Admin)
                    if (!isAdmin) _ContactIconButton(isAdmin: isAdmin),
                    if (isAdmin) ...[
                      // Logout button — admin only
                      _AdminLogoutButton(),
                    ],
                    if (!isAdmin) ...[
                      // Subscription button — non-admin only (hidden when subscribed)
                      _SubscriptionButton(),
                    ],
                  ],
                )
              else
                _GuestMenuButton(),
            ],
          ),
        );
      },
    );
  }
}

class _ContactIconButton extends StatefulWidget {
  final bool isAdmin;

  const _ContactIconButton({required this.isAdmin});

  @override
  State<_ContactIconButton> createState() => _ContactIconButtonState();
}

class _ContactIconButtonState extends State<_ContactIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: appTranslation().get('contact_support'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.isAdmin) {
              context.push(Routes.adminContact);
            } else {
              context.push(Routes.contact);
            }
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorsManager.goldLight, width: 1.5),
              color: ColorsManager.surfacePrimary,
            ),
            child: RotationTransition(
              turns: _animation,
              child: Icon(
                Icons.phone_outlined,
                size: 20,
                color: ColorsManager.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminLogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      bloc: sl<ProfileCubit>(),
      listener: (context, state) {
        if (state is ProfileLogoutSuccessState) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.login,
            (route) => false,
          );
        }
      },
      child: PrimaryElevatedButton(
        icon: const Icon(
          Icons.logout,
          size: 18,
          color: ColorsManager.white,
        ),
        text: appTranslation().get('logout'),
        textStyle: TextStylesManager.bold13.copyWith(
          color: ColorsManager.white,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => LogoutDialog(
              onConfirm: () => sl<ProfileCubit>().logout(),
            ),
          );
        },
        width: 140,
        height: 42,
        radius: 24,
      ),
    );
  }
}

class _SubscriptionButton extends StatefulWidget {
  @override
  State<_SubscriptionButton> createState() => _SubscriptionButtonState();
}

class _SubscriptionButtonState extends State<_SubscriptionButton> {
  @override
  void initState() {
    super.initState();
    final cubit = sl<SubscriptionCubit>();
    if (cubit.currentSubscription == null && cubit.lastError == null) {
      cubit.fetchCurrentSubscription();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, dynamic>(
      bloc: sl<SubscriptionCubit>(),
      builder: (context, state) {
        final current = sl<SubscriptionCubit>().currentSubscription;
        final teacher = sl<ProfileCubit>().profileModel?.teacher;

        final bool isSubscribed = current?.isSubscribed ?? teacher?.isSubscribed ?? false;
        final bool isInTrial = current?.isInTrial ?? teacher?.isInTrial ?? false;
        final DateTime? trialEndsAt = current?.trialEndsAt ?? teacher?.trialEndsAt;
        final DateTime? subscriptionEndsAt = current?.subscriptionEndsAt ?? teacher?.subscriptionEndsAt;
        final DateTime? effectiveEndsAt = isSubscribed
            ? subscriptionEndsAt
            : (isInTrial ? trialEndsAt : (subscriptionEndsAt ?? trialEndsAt));

        int daysRemaining = 0;
        if (effectiveEndsAt != null) {
          final now = DateTime.now();
          if (effectiveEndsAt.isAfter(now)) {
            daysRemaining = (effectiveEndsAt.difference(now).inHours / 24).ceil();
          }
        } else {
          daysRemaining = current?.trialDaysRemaining ?? teacher?.trialDaysRemaining ?? 0;
        }

        final bool isExpired;
        if (isSubscribed) {
          isExpired = subscriptionEndsAt != null && subscriptionEndsAt.isBefore(DateTime.now());
        } else if (isInTrial) {
          isExpired = (trialEndsAt != null && trialEndsAt.isBefore(DateTime.now())) || daysRemaining <= 0;
        } else {
          isExpired = true;
        }

        Color buttonColor;
        String buttonText;
        IconData buttonIcon;

        if (isSubscribed && !isExpired) {
          // Subscribed & Active
          buttonColor = const Color(0xFF0E7A5E);
          buttonText = 'اشتراك نشط';
          buttonIcon = Icons.verified_user_outlined;
        } else if (isExpired) {
          // Expired
          buttonColor = const Color(0xFFDC2626);
          buttonText = 'انتهى الاشتراك';
          buttonIcon = Icons.lock_clock_outlined;
        } else if (isInTrial) {
          // Trial Active
          if (daysRemaining <= 3) {
            buttonColor = const Color(0xFFF97316); // Warning Orange
            buttonText = daysRemaining <= 1 ? 'آخر يوم تجربة' : 'متبقي $daysRemaining أيام';
            buttonIcon = Icons.hourglass_top_rounded;
          } else {
            buttonColor = const Color(0xFFD97706); // Amber Gold
            buttonText = 'تجربة مجانية';
            buttonIcon = Icons.auto_awesome;
          }
        } else {
          // Default fallback
          buttonColor = const Color(0xFF0E7A5E);
          buttonText = 'الاشتراك';
          buttonIcon = Icons.workspace_premium_outlined;
        }

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: PrimaryElevatedButton(
            icon: Icon(
              buttonIcon,
              size: 18,
              color: ColorsManager.white,
            ),
            text: buttonText,
            backgroundColor: buttonColor,
            textStyle: TextStylesManager.bold13.copyWith(
              color: ColorsManager.white,
            ),
            onPressed: () => SubscriptionStatusDialog.show(context),
            width: 140,
            height: 42,
            radius: 24,
          ),
        );
      },
    );
  }
}

class _GuestMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'register') {
          context.push(Routes.register);
        } else if (value == 'login') {
          context.push(Routes.login);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'register',
          child: Row(
            children: [
              const Icon(Icons.person_add_alt_1_outlined, size: 20),
              horizontalSpace10,
              Text(
                appTranslation().get('create_account'),
                style: TextStylesManager.bold14,
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'login',
          child: Row(
            children: [
              const Icon(Icons.login_outlined, size: 20),
              horizontalSpace10,
              Text(
                appTranslation().get('login'),
                style: TextStylesManager.bold14,
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ColorsManager.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add_alt_1_outlined,
                size: 20, color: ColorsManager.white),
            horizontalSpace8,
            Text(
              appTranslation().get('create_account'),
              style: TextStylesManager.bold14.copyWith(
                  color: ColorsManager.white),
            ),
            horizontalSpace6,
            const Icon(Icons.arrow_drop_down, color: ColorsManager.white),
          ],
        ),
      ),
    );
  }
}

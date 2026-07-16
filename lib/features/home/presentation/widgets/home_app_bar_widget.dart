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
                    // Phone icon button — contact
                    _ContactIconButton(isAdmin: isAdmin),
                    if (isAdmin) ...[
                      horizontalSpace8,
                      // Admin Payments button — admin only
                      _AdminPaymentsButton(),
                    ],
                    if (!isAdmin) ...[
                      horizontalSpace8,
                      // Subscription button — non-admin only
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

class _AdminPaymentsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PrimaryElevatedButton(
      icon: Icon(
        Icons.payments_outlined,
        size: 18,
        color: ColorsManager.white,
      ),
      text: appTranslation().get('admin_payments_title'),
      textStyle: TextStylesManager.bold13.copyWith(
        color: ColorsManager.white,
      ),
      onPressed: () => context.push(Routes.adminPayments),
      width: 140,
      height: 42,
      radius: 24,
    );
  }
}

class _SubscriptionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PrimaryElevatedButton(
      icon: Icon(
        Icons.workspace_premium_outlined,
        size: 18,
        color: ColorsManager.white,
      ),
      text: appTranslation().get('pay_subscription_btn'),
      textStyle: TextStylesManager.bold13.copyWith(
        color: ColorsManager.white,
      ),
      onPressed: () => context.push(Routes.checkout),
      width: 140,
      height: 42,
      radius: 24,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:moean/features/profile/presentation/cubit/profile_state.dart';
import 'package:moean/features/profile/presentation/widgets/profile_info_card.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_state.dart';
import 'package:moean/core/di/injections.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    sl<ProfileCubit>().fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      bloc: sl<ProfileCubit>(),
      listener: (context, state) {
        if (state is ProfileLogoutSuccessState) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final cubit = sl<ProfileCubit>();
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return Scaffold(
              backgroundColor: ColorsManager.background,
              appBar: AppBar(
                backgroundColor: ColorsManager.surfacePrimary,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  appTranslation().get('profile'),
                  style: TextStylesManager.bold18.copyWith(
                    color: ColorsManager.textPrimary,
                  ),
                ),
              ),
              body: ConditionalBuilder(
                loadingState: state is ProfileLoadingState && cubit.profileModel == null,
                errorState: state is ProfileErrorState && cubit.profileModel == null,
                errorBuilder: (context) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (state as ProfileErrorState).message,
                          textAlign: TextAlign.center,
                          style: TextStylesManager.regular16.copyWith(color: ColorsManager.errorColor),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            cubit.fetchProfile(forceRefresh: true);
                            sl<SubscriptionCubit>().fetchCurrentSubscription(forceRefresh: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(appTranslation().get('retry')),
                        ),
                      ],
                    ),
                  ),
                ),
                successBuilder: (context) {
                  final profile = cubit.profileModel;
                  if (profile == null) return const SizedBox.shrink();

                  // Bottom padding = bottom nav bar height (60) + system nav inset
                  final double bottomInset =
                      MediaQuery.of(context).padding.bottom + 60 + 24;

                  return RefreshIndicator(
                    color: ColorsManager.primaryColor,
                    onRefresh: () async {
                      await Future.wait([
                        sl<ProfileCubit>().fetchProfile(forceRefresh: true),
                        sl<SubscriptionCubit>().fetchCurrentSubscription(forceRefresh: true),
                      ]);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: ColorsManager.primaryColor, width: 2),
                              ),
                              child: Icon(Icons.person, size: 50, color: ColorsManager.primaryColor),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              profile.user.name,
                              style: TextStylesManager.bold20.copyWith(color: ColorsManager.textPrimary),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ProfileInfoCard(
                            icon: Icons.email_outlined,
                            title: appTranslation().get('email'),
                            value: profile.user.email,
                          ),
                          if (profile.role != null)
                            ProfileInfoCard(
                              icon: Icons.work_outline,
                              title: appTranslation().get('role'),
                              value: profile.role!,
                            ),
                          if (profile.phone != null)
                            ProfileInfoCard(
                              icon: Icons.phone_outlined,
                              title: appTranslation().get('phone_number'),
                              value: profile.phone!,
                            ),
                          if (profile.subscriptionName != null)
                            ProfileInfoCard(
                              icon: Icons.star_border,
                              title: appTranslation().get('subscription'),
                              value: profile.subscriptionName!,
                              iconColor: ColorsManager.secondaryColor,
                            ),
                          BlocBuilder<SubscriptionCubit, SubscriptionState>(
                            bloc: sl<SubscriptionCubit>(),
                            builder: (context, subState) {
                              if (subState is SubscriptionLoaded) {
                                final usage = subState.current.usage;
                                return Column(
                                  children: [
                                    ProfileInfoCard(
                                      icon: Icons.auto_awesome_outlined,
                                      title: 'رصيد الذكاء الاصطناعي',
                                      value: usage.aiRemaining.toString(),
                                      iconColor: ColorsManager.themePink,
                                    ),
                                    ProfileInfoCard(
                                      icon: Icons.chrome_reader_mode_outlined,
                                      title: 'الدروس المتبقية لليوم',
                                      value: usage.lessonsRemainingToday.toString(),
                                      iconColor: ColorsManager.primaryColor,
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          ProfileInfoCard(
                            icon: profile.madrasatiConnected ? Icons.link : Icons.link_off,
                            title: appTranslation().get('madrasati_status'),
                            value: profile.madrasatiConnected
                                ? appTranslation().get('connected')
                                : appTranslation().get('not_connected'),
                            iconColor: profile.madrasatiConnected ? ColorsManager.successColor : ColorsManager.errorColor,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

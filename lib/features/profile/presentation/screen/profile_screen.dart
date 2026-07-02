import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:moean/features/profile/presentation/cubit/profile_state.dart';
import 'package:moean/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:moean/features/profile/presentation/widgets/profile_info_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit()..fetchProfile(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
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
          final cubit = ProfileCubit.get(context);
          return Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: AppBar(
  backgroundColor: ColorsManager.surfacePrimary,
  elevation: 0,
  centerTitle: true,

  // // سهم iOS
  // leading: IconButton(
  //   icon: const Icon(
  //     Icons.arrow_back_ios,
  //     size: 24,
  //   ),
  //   color: ColorsManager.primaryColor,
  //   onPressed: () {
  //     Navigator.pop(context);
  //   },
  // ),

  title: Text(
    appTranslation().get('profile'),
    style: TextStylesManager.bold18.copyWith(
      color: ColorsManager.textPrimary,
    ),
  ),

  // actions: [
  //   IconButton(
  //     icon: const Icon(
  //       Icons.settings,
  //     ),
  //     color: ColorsManager.primaryColor,
  //     onPressed: () {
  //       Navigator.pushNamed(context, Routes.settings);
  //     },
  //   ),
  // ],
),
            body: ConditionalBuilder(
              loadingState: state is ProfileLoadingState,
              errorState: state is ProfileErrorState,
              errorBuilder: (context) => Center(
                child: Text(
                  (state as ProfileErrorState).message,
                  style: TextStylesManager.regular16.copyWith(color: ColorsManager.errorColor),
                ),
              ),
              successBuilder: (context) {
                final profile = cubit.profileModel;
                if (profile == null) return const SizedBox.shrink();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
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
                      if (profile.aiQuotaRemaining != null)
                        ProfileInfoCard(
                          icon: Icons.auto_awesome_outlined,
                          title: appTranslation().get('ai_quota'),
                          value: profile.aiQuotaRemaining.toString(),
                          iconColor: ColorsManager.themePink,
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}

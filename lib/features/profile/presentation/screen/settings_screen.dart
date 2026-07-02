import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';
import 'package:moean/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:moean/features/profile/presentation/cubit/profile_state.dart';
import 'package:moean/features/profile/presentation/widgets/logout_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
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
          final profileCubit = ProfileCubit.get(context);
          return Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: AppBar(
              backgroundColor: ColorsManager.surfacePrimary,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 24,
                ),
                color: ColorsManager.primaryColor,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                appTranslation().get('settings'),
                style: TextStylesManager.bold18.copyWith(
                  color: ColorsManager.textPrimary,
                ),
              ),
            ),
            body: BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                final themeCubit = ThemeCubit.get(context);
                return ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    // Dark Mode Toggle
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        themeCubit.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: ColorsManager.primaryColor,
                      ),
                      title: Text(
                        appTranslation().get('dark_mode'),
                        style: TextStylesManager.medium16.copyWith(
                          color: ColorsManager.textPrimary,
                        ),
                      ),
                      trailing: Switch(
                        value: themeCubit.isDarkMode,
                        onChanged: (value) {
                          themeCubit.changeTheme();
                        },
                        activeColor: ColorsManager.primaryColor,
                      ),
                    ),
                    const Divider(),
                    // Language Toggle
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:  Icon(
                        Icons.language,
                        color: ColorsManager.primaryColor,
                      ),
                      title: Text(
                        appTranslation().get('language'),
                        style: TextStylesManager.medium16.copyWith(
                          color: ColorsManager.textPrimary,
                        ),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: ColorsManager.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<bool>(
                            value: themeCubit.isArabicLang,
                            icon:  Icon(Icons.arrow_drop_down, color: ColorsManager.primaryColor),
                            onChanged: (bool? newValue) {
                              if (newValue != null && newValue != themeCubit.isArabicLang) {
                                themeCubit.changeLanguage();
                              }
                            },
                            items: [
                              DropdownMenuItem(
                                value: true,
                                child: Text(
                                  appTranslation().get('arabic'),
                                  style: TextStylesManager.medium14.copyWith(
                                    color: ColorsManager.primaryColor,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Text(
                                  appTranslation().get('english'),
                                  style: TextStylesManager.medium14.copyWith(
                                    color: ColorsManager.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    // Logout Button
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.logout,
                        color: ColorsManager.errorColor,
                      ),
                      title: Text(
                        appTranslation().get('logout'),
                        style: TextStylesManager.medium16.copyWith(
                          color: ColorsManager.errorColor,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => LogoutDialog(
                            onConfirm: () => profileCubit.logout(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

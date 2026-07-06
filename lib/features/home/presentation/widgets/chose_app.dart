import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/home/presentation/widgets/chose_app_header.dart';
import 'package:moean/features/home/presentation/widgets/chose_app_option_card.dart';

class ChoseApp extends StatefulWidget {
  const ChoseApp({super.key});

  @override
  State<ChoseApp> createState() => _ChoseAppState();
}

class _ChoseAppState extends State<ChoseApp> {
  // 0 = extension, 1 = mobile app (disabled/coming soon)
  int _selected = 0;

  void _onContinue() {
    if (_selected == 0) {
      Navigator.pushNamed(context, Routes.addextention);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ColorsManager.background,
        appBar: AppBar(
  backgroundColor: ColorsManager.background,
  elevation: 0,
    centerTitle: true,

  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios),
    onPressed: () => Navigator.pop(context),
  ),
  title: Text(
    appTranslation().get('app_name'),
    style: TextStylesManager.bold20.copyWith(
      color: ColorsManager.primaryColor,
    ),
  ),
  actions: [
    Image.asset(
      AssetsHelper.icon,
      width: 55,
      height: 55,
      fit: BoxFit.cover,
    ),
  ],
),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────────────────
                ChoseAppHeader(
                  title: appTranslation().get('chose_app_title'),
                  subtitle: appTranslation().get('chose_app_subtitle'),
                ),

                verticalSpace40,

                // ── Option 1: Browser Extension ──────────────────────
                ChoseAppOptionCard(
                  icon: Icons.extension_rounded,
                  title: appTranslation().get('chose_app_extension_title'),
                  subtitle: appTranslation().get('chose_app_extension_subtitle'),
                  badge: appTranslation().get('chose_app_extension_badge'),
                  badgeActive: true,
                  isSelected: _selected == 0,
                  onTap: () => setState(() => _selected = 0),
                ),

                verticalSpace16,

                // ── Option 2: Mobile App (Coming Soon) ───────────────
                ChoseAppOptionCard(
                  icon: Icons.phone_iphone_rounded,
                  title: appTranslation().get('chose_app_app_title'),
                  subtitle: appTranslation().get('chose_app_app_subtitle'),
                  badge: appTranslation().get('chose_app_app_badge'),
                  badgeActive: false,
                  isSelected: _selected == 1,
                  isDisabled: true,
                  onTap: null,
                ),

                verticalSpace40,

                // ── Continue Button ──────────────────────────────────
                PrimaryElevatedButton(
                  onPressed: _onContinue,
                  text: appTranslation().get('chose_app_continue'),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),

               
              ],
            ),
          ),
        ),
      ),
    );
  }
}
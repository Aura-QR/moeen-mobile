import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/network/local/secure_storage_helper.dart';

class HomeAppBarWidget extends StatelessWidget {
  const HomeAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
          (token != null && token!.isNotEmpty)
              ? PrimaryElevatedButton(
                  icon: const Icon(Icons.logout, size: 20),
                  text: 'تسجيل خروج',
                  textStyle: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.white,
                  ),
                  onPressed: () async {
                    await sl<SecureStorageHelper>().clearAll();
                    token = null;
                    if (context.mounted) {
                      context.pushNamedAndRemoveUntil(Routes.home, (route) => false);
                    }
                  },
                  width: 150,
                )
              : PopupMenuButton<String>(
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
                        const Icon(Icons.person_add_alt_1_outlined, size: 20, color: ColorsManager.white),
                        horizontalSpace8,
                        Text(
                          appTranslation().get('create_account'),
                          style: TextStylesManager.bold14.copyWith(color: ColorsManager.white),
                        ),
                        horizontalSpace6,
                        const Icon(Icons.arrow_drop_down, color: ColorsManager.white),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

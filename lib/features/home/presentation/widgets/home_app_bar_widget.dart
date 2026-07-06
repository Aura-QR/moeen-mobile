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
              : PrimaryElevatedButton(
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
                  text: appTranslation().get('create_account'),
                  textStyle: TextStylesManager.bold14.copyWith(
                    color: ColorsManager.white,
                  ),
                  onPressed: () {
                    context.push(Routes.register);
                  },
                  width: 150,
                ),
        
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/assets_helper.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/cubit/theme/theme_cubit.dart';
import 'package:moean/core/utils/cubit/theme/theme_state.dart';

class RegisterHeaderWidget extends StatelessWidget {
  const RegisterHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            AssetsHelper.logo,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        horizontalSpace12,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appTranslation().get('app_name'),
              style: TextStylesManager.bold22.copyWith(
                color: ColorsManager.primaryColor,
              ),
            ),
            Text(
              appTranslation().get('smart_assistant'),
              style: TextStylesManager.medium14.copyWith(
                color: ColorsManager.placeholder,
              ),
            ),
          ],
        ),
        const Spacer(),
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return IconButton(
              onPressed: () {
                ThemeCubit.get(context).changeTheme();
              },
              icon: Icon(
                ThemeCubit.get(context).isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: ColorsManager.primaryColor,
              ),
            );
          },
        ),
      ],
    );
  }
}

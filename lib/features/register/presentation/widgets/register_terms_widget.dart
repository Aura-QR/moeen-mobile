import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/features/register/presentation/cubit/register_cubit.dart';
import 'package:moean/features/register/presentation/cubit/register_state.dart';

class RegisterTermsWidget extends StatelessWidget {
  const RegisterTermsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = RegisterCubit.get(context);

    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (prev, curr) => curr is RegisterTermsChangedState,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: cubit.toggleTerms,
                child: Text(
                  appTranslation().get('terms_agree'),
                  style: TextStylesManager.regular14.copyWith(
                    color: ColorsManager.primaryColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Checkbox(
                value: cubit.agreeToTerms,
                onChanged: (_) => cubit.toggleTerms(),
                activeColor: ColorsManager.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: ColorsManager.borderColor,
                  width: 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

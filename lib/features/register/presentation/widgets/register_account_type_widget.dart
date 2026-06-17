import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/register/presentation/cubit/register_cubit.dart';
import 'package:moean/features/register/presentation/cubit/register_state.dart';

class RegisterAccountTypeWidget extends StatelessWidget {
  const RegisterAccountTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = RegisterCubit.get(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          appTranslation().get('account_type'),
          style: TextStylesManager.medium14.copyWith(
            color: ColorsManager.mainText,
          ),
        ),
        verticalSpace8,
        BlocBuilder<RegisterCubit, RegisterState>(
          buildWhen: (prev, curr) => curr is RegisterAccountTypeChangedState,
          builder: (context, state) {
            return Row(
              children: [
               
                _AccountTypeOptionWidget(
                  label: appTranslation().get('account_type_teacher'),
                  icon: Icons.person_outline_rounded,
                  isSelected: cubit.selectedAccountType == AccountType.teacher,
                  onTap: () => cubit.setAccountType(AccountType.teacher),
                ),
                horizontalSpace12,
               
                 _AccountTypeOptionWidget(
                  label: appTranslation().get('account_type_supervisor'),
                  icon: Icons.manage_accounts_outlined,
                  isSelected:
                      cubit.selectedAccountType == AccountType.supervisor,
                  onTap: () => cubit.setAccountType(AccountType.supervisor),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AccountTypeOptionWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeOptionWidget({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? ColorsManager.primaryColor
                  : ColorsManager.borderColor,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: ColorsManager.white,
                ),
                horizontalSpace6,
              ] else ...[
                Icon(
                  icon,
                  size: 18,
                  color: ColorsManager.mainText,
                ),
                horizontalSpace6,
              ],
              Text(
                label,
                style: TextStylesManager.medium14.copyWith(
                  color: isSelected
                      ? ColorsManager.white
                      : ColorsManager.mainText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

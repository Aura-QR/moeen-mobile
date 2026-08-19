import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_cubit.dart';
import 'package:moean/features/account_suspended/presentation/cubit/account_suspended_state.dart';

class SuspendedTicketTypeDropdownWidget extends StatelessWidget {
  const SuspendedTicketTypeDropdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSuspendedCubit, AccountSuspendedState>(
      buildWhen: (previous, current) =>
          current is AccountSuspendedTypesLoadedState ||
          current is AccountSuspendedTypeSelectedState,
      builder: (context, state) {
        final cubit = AccountSuspendedCubit.get(context);

        final items = cubit.contactTypes.map<DropdownMenuItem<String>>((type) {
          final val = (type is Map ? type['value'] : type.toString()).toString();
          final lbl = (type is Map ? type['label'] : type.toString()).toString();
          return DropdownMenuItem<String>(
            value: val,
            child: Text(
              lbl,
              style: TextStylesManager.regular14.copyWith(
                color: ColorsManager.textPrimary,
              ),
            ),
          );
        }).toList();

        final isValidSelection =
            cubit.contactTypes.any((t) => (t is Map ? t['value'] : t.toString()).toString() == cubit.selectedType);
        final value = isValidSelection ? cubit.selectedType : (items.isNotEmpty ? items.first.value : null);

        return Container(
          decoration: BoxDecoration(
            color: ColorsManager.surfacePrimary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ColorsManager.borderColor,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ColorsManager.textSecondaryDark,
              ),
              dropdownColor: ColorsManager.surfacePrimary,
              borderRadius: BorderRadius.circular(16),
              items: items,
              onChanged: (newVal) {
                if (newVal != null) {
                  cubit.selectType(newVal);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

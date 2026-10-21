import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';

/// Changing the role adds that role's standard items right away.
class PortfolioRoleDropdownWidget extends StatelessWidget {
  const PortfolioRoleDropdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioEditorCubit, PortfolioEditorState>(
      buildWhen: (previous, current) =>
          previous.roles != current.roles ||
          previous.portfolio?.role != current.portfolio?.role ||
          previous.isSaving != current.isSaving,
      builder: (context, state) {
        final roles = state.roles?.roles ?? const [];
        final current = state.portfolio!.role;
        final hasCurrent = roles.any((role) => role.key == current);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: hasCurrent ? current : null,
              isExpanded: true,
              hint: Text(state.portfolio!.roleLabel, style: TextStylesManager.regular14),
              decoration: InputDecoration(
                labelText: appTranslation().get('portfolio_role'),
                filled: true,
                fillColor: ColorsManager.surfacePrimary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: ColorsManager.borderLightGray),
                ),
              ),
              items: [
                for (final role in roles)
                  DropdownMenuItem(
                    value: role.key,
                    child: Text(role.label, style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText)),
                  ),
              ],
              onChanged: state.isSaving
                  ? null
                  : (role) {
                      if (role != null) PortfolioEditorCubit.get(context).changeRole(role);
                    },
            ),
            verticalSpace6,
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: ColorsManager.secondaryText),
                horizontalSpace6,
                Expanded(
                  child: Text(
                    appTranslation().get('portfolio_role_change_note'),
                    style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

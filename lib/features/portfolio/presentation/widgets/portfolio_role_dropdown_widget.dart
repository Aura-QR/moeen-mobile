import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_confirm_dialog.dart';
import 'package:moean/core/utils/constants/primary/primary_dropdown_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';

/// Changing the role adds that role's evaluation form right away, after the
/// teacher confirms. Cancelling leaves the current role selected.
class PortfolioRoleDropdownWidget extends StatelessWidget {
  const PortfolioRoleDropdownWidget({super.key});

  Future<void> _change(BuildContext context, String? role) async {
    final cubit = PortfolioEditorCubit.get(context);
    if (role == null || role == cubit.state.portfolio?.role) return;
    final confirmed = await showPrimaryConfirmDialog(
      context,
      titleKey: 'portfolio_role_change_title',
      messageKey: 'portfolio_role_change_confirm',
      confirmKey: 'document_element_change',
      icon: Icons.swap_horiz_rounded,
      iconColor: ColorsManager.primaryColor,
    );
    if (confirmed) cubit.changeRole(role);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioEditorCubit, PortfolioEditorState>(
      buildWhen: (previous, current) =>
          previous.roles != current.roles ||
          previous.portfolio?.role != current.portfolio?.role ||
          previous.isSaving != current.isSaving,
      builder: (context, state) {
        final roles = state.roles?.roles ?? const [];
        final labels = {for (final role in roles) role.key: role.label};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryDropdownField<String>(
              label: appTranslation().get('portfolio_role'),
              hint: state.portfolio!.roleLabel,
              value: state.portfolio!.role,
              items: labels.keys.toList(),
              labelOf: (key) => labels[key] ?? key,
              enabled: !state.isSaving,
              onChanged: (role) => _change(context, role),
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

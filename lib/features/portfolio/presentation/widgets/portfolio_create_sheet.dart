import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_snack_bar.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_list_cubit.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_role_option_widget.dart';

/// Role picker and optional title. Pops with the created portfolio.
class PortfolioCreateSheet extends StatefulWidget {
  const PortfolioCreateSheet({super.key});

  @override
  State<PortfolioCreateSheet> createState() => _PortfolioCreateSheetState();
}

class _PortfolioCreateSheetState extends State<PortfolioCreateSheet> {
  final _titleController = TextEditingController();
  String? _selectedRole;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PortfolioListCubit, PortfolioListState>(
      listenWhen: (_, current) => current.created != null || current.feedback != null,
      listener: (context, state) {
        if (state.created != null) {
          Navigator.pop(context, state.created);
        } else {
          showPrimarySnackBar(context, state.feedback!);
        }
      },
      buildWhen: (previous, current) =>
          previous.roles != current.roles ||
          previous.isLoadingRoles != current.isLoadingRoles ||
          previous.isCreating != current.isCreating,
      builder: (context, state) {
        final roles = state.roles?.roles ?? const [];
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  appTranslation().get('portfolio_create'),
                  style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
                ),
                verticalSpace16,
                Text(
                  appTranslation().get('portfolio_role'),
                  style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
                ),
                verticalSpace8,
                if (state.isLoadingRoles)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                for (final role in roles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PortfolioRoleOptionWidget(
                      role: role,
                      isSelected: role.key == _selectedRole,
                      onTap: () => setState(() => _selectedRole = role.key),
                    ),
                  ),
                verticalSpace8,
                PrimaryTextField(
                  controller: _titleController,
                  hint: appTranslation().get('portfolio_title_hint'),
                  textInputAction: TextInputAction.done,
                ),
                verticalSpace20,
                PrimaryElevatedButton(
                  text: appTranslation().get('portfolio_create'),
                  isLoading: state.isCreating,
                  onPressed: _selectedRole == null
                      ? null
                      : () => PortfolioListCubit.get(context).createPortfolio(
                            role: _selectedRole!,
                            title: _titleController.text,
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

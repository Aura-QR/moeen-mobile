import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/router/app_router.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/role_suites/data/models/role_suite_models.dart';
import 'package:moean/features/role_suites/presentation/cubit/role_suites_cubit.dart';
import 'package:moean/features/role_suites/presentation/widgets/role_suite_card.dart';

/// L1 «حقائب الأدوار» (`/tools/roles`): displays the 4 role cards.
class RoleSuitesScreen extends StatelessWidget {
  const RoleSuitesScreen({super.key});

  void _openRole(BuildContext context, RoleSuiteSummary role) {
    AppRouter.push(
      AppRouter.roleDocumentsPath(role.key),
      arguments: role,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = RoleSuitesCubit.get(context);
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('role_suites_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocBuilder<RoleSuitesCubit, RoleSuitesState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.roles != current.roles ||
            previous.matchedRoleKey != current.matchedRoleKey,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == RoleSuitesStatus.loading,
          errorState: state.status == RoleSuitesStatus.failure,
          emptyState: state.roles.isEmpty,
          errorBuilder: (_) => PrimaryErrorView(
            message: state.errorMessage ?? 'generic_error',
            onRetry: cubit.load,
          ),
          emptyBuilder: (_) => NoDataWidget(
            icon: Icons.work_outline_rounded,
            title: appTranslation().get('role_suites_empty'),
          ),
          successBuilder: (_) => RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  appTranslation().get('role_suites_subtitle'),
                  style: TextStylesManager.regular13.copyWith(color: ColorsManager.secondaryText),
                ),
                verticalSpace14,
                for (final role in state.roles)
                  RoleSuiteCard(
                    role: role,
                    isMatched: role.key == state.matchedRoleKey,
                    onTap: () => _openRole(context, role),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

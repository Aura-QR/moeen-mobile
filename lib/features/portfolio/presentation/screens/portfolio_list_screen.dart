import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/primary/no_data_widget.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_error_view.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/portfolio/data/models/portfolio_model.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_list_cubit.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_card_widget.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_create_sheet.dart';

class PortfolioListScreen extends StatelessWidget {
  const PortfolioListScreen({super.key});

  /// Opens the editor and refreshes on return, since completion may change.
  Future<void> _openEditor(BuildContext context, int id) async {
    final cubit = PortfolioListCubit.get(context);
    await Navigator.pushNamed(context, Routes.portfolioEditor, arguments: id);
    cubit.loadPortfolios();
  }

  Future<void> _openCreateSheet(BuildContext context) async {
    final cubit = PortfolioListCubit.get(context)..loadRoles();
    final created = await showModalBottomSheet<PortfolioModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorsManager.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => BlocProvider.value(value: cubit, child: const PortfolioCreateSheet()),
    );
    if (created != null && context.mounted) _openEditor(context, created.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.background,
      appBar: AppBar(
        backgroundColor: ColorsManager.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          appTranslation().get('portfolio_title'),
          style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
        ),
      ),
      body: BlocBuilder<PortfolioListCubit, PortfolioListState>(
        buildWhen: (previous, current) =>
            previous.status != current.status || previous.portfolios != current.portfolios,
        builder: (context, state) => ConditionalBuilder(
          loadingState: state.status == PortfolioListStatus.loading ||
              state.status == PortfolioListStatus.initial,
          errorState: state.status == PortfolioListStatus.failure,
          emptyState: state.portfolios.isEmpty,
          errorBuilder: (_) => PrimaryErrorView(
            message: state.errorMessage ?? 'generic_error',
            onRetry: PortfolioListCubit.get(context).loadPortfolios,
          ),
          emptyBuilder: (_) => NoDataWidget(
            icon: Icons.workspace_premium_outlined,
            title: appTranslation().get('portfolio_empty_title'),
            subtitle: appTranslation().get('portfolio_empty_subtitle'),
          ),
          successBuilder: (_) => RefreshIndicator(
            onRefresh: PortfolioListCubit.get(context).loadPortfolios,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: state.portfolios.length,
              separatorBuilder: (_, _) => verticalSpace12,
              itemBuilder: (context, index) => PortfolioCardWidget(
                portfolio: state.portfolios[index],
                onTap: () => _openEditor(context, state.portfolios[index].id),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Builder(
          builder: (context) => PrimaryElevatedButton(
            text: appTranslation().get('portfolio_create'),
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openCreateSheet(context),
          ),
        ),
      ),
    );
  }
}

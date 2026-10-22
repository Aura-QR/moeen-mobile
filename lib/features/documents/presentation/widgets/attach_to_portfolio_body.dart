import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/documents/presentation/cubit/attach_to_portfolio_cubit.dart';
import 'package:moean/features/documents/presentation/widgets/attach_choice_tile.dart';

/// The portfolio list, then the chosen portfolio's items.
class AttachToPortfolioBody extends StatelessWidget {
  const AttachToPortfolioBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttachToPortfolioCubit, AttachToPortfolioState>(
      buildWhen: (previous, current) =>
          previous.portfolios != current.portfolios ||
          previous.portfolio != current.portfolio ||
          previous.isLoadingItems != current.isLoadingItems ||
          previous.selectedItemId != current.selectedItemId ||
          previous.isAttaching != current.isAttaching,
      builder: (context, state) {
        final cubit = AttachToPortfolioCubit.get(context);
        final items = state.portfolio?.items ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appTranslation().get('document_attach_pick_portfolio'),
              style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
            ),
            verticalSpace8,
            for (final portfolio in state.portfolios)
              AttachChoiceTile(
                title: portfolio.title,
                subtitle: portfolio.roleLabel,
                isSelected: state.portfolio?.id == portfolio.id,
                onTap: () => cubit.selectPortfolio(portfolio.id),
              ),
            if (state.isLoadingItems)
              const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
            if (items.isNotEmpty) ...[
              verticalSpace12,
              Text(
                appTranslation().get('document_attach_pick_item'),
                style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
              ),
              verticalSpace8,
              for (final item in items)
                AttachChoiceTile(
                  title: item.title,
                  isSelected: state.selectedItemId == item.id,
                  onTap: () => cubit.selectItem(item.id),
                ),
            ],
            verticalSpace16,
            PrimaryElevatedButton(
              text: appTranslation().get('document_attach_confirm'),
              icon: const Icon(Icons.add_task_rounded, size: 20),
              isLoading: state.isAttaching,
              onPressed: state.selectedItemId == null ? null : cubit.attach,
            ),
          ],
        );
      },
    );
  }
}

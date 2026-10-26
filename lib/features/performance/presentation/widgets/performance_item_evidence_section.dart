import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/features/portfolio/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:moean/features/portfolio/presentation/widgets/portfolio_item_card_widget.dart';

/// The item's own evidence, with the portfolio editor's upload, link and
/// delete, so both screens work the same.
class PerformanceItemEvidenceSection extends StatelessWidget {
  final int itemId;

  const PerformanceItemEvidenceSection({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioEditorCubit, PortfolioEditorState>(
      buildWhen: (previous, current) => previous.portfolio != current.portfolio,
      builder: (context, state) {
        final item = state.portfolio?.items.where((item) => item.id == itemId).firstOrNull;
        if (item == null) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return PortfolioItemCardWidget(item: item, initiallyExpanded: true);
      },
    );
  }
}

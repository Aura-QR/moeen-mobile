import 'package:flutter/material.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/performance/presentation/cubit/performance_cubit.dart';
import 'package:moean/features/performance/presentation/widgets/performance_cv_section.dart';
import 'package:moean/features/performance/presentation/widgets/performance_export_sheet.dart';
import 'package:moean/features/performance/presentation/widgets/performance_header_card.dart';
import 'package:moean/features/performance/presentation/widgets/performance_item_card.dart';
import 'package:moean/features/portfolio/data/models/performance_model.dart';

/// The summary, the CV and one card per element.
class PerformanceBody extends StatelessWidget {
  final PerformanceModel performance;

  const PerformanceBody({super.key, required this.performance});

  Future<void> _openItem(BuildContext context, PerformanceItemModel item) async {
    final cubit = PerformanceCubit.get(context);
    await Navigator.pushNamed(
      context,
      Routes.portfolioPerformanceItem,
      arguments: (portfolioId: performance.portfolioId, itemId: item.id),
    );
    cubit.refresh();
  }

  Future<void> _export(BuildContext context) async {
    final cubit = PerformanceCubit.get(context);
    await PerformanceExportSheet.show(context, portfolioId: performance.portfolioId);
    cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = PerformanceCubit.get(context);
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          PerformanceHeaderCard(performance: performance, onExport: () => _export(context)),
          verticalSpace12,
          PerformanceCvSection(cv: performance.cv),
          verticalSpace12,
          for (final item in performance.items) ...[
            PerformanceItemCard(
              item: item,
              ratingMax: performance.ratingMax,
              onTap: () => _openItem(context, item),
            ),
            verticalSpace10,
          ],
        ],
      ),
    );
  }
}

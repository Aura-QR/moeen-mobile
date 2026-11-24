import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/data/models/activities_catalogue_model.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_ein_link.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_summary_row.dart';

/// Under the official grid: the periods per domain and the total against the
/// term's available periods, then the link to the non-class timeline.
class ActivitiesSummarySection extends StatelessWidget {
  final ActivitiesPlanState state;

  const ActivitiesSummarySection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final summary = state.officialSummary;
    if (summary == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        verticalSpace8,
        Text(
          appTranslation().get('activities_plan_summary_title'),
          style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
        ),
        verticalSpace8,
        for (final domain in summary.domains)
          ActivitiesSummaryRow(
            label: domain.label,
            periods: domain.periods,
            // «الأيام والمناسبات» is not a domain the guide asks to balance.
            isWarning: domain.periods == 0 && domain.key != ActivitiesCatalogueModel.occasionsKey,
          ),
        verticalSpace8,
        Text(
          appTranslation()
              .get('activities_plan_summary_total')
              .replaceAll('{total}', '${summary.total}')
              .replaceAll('{target}', '${summary.target}'),
          style: TextStylesManager.bold13.copyWith(color: ColorsManager.primaryColor),
        ),
        if (state.catalogue.einUrl.isNotEmpty) ...[verticalSpace12, ActivitiesEinLink(url: state.catalogue.einUrl)],
      ],
    );
  }
}

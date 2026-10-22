import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_choice_chips.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/activities_plan/presentation/cubit/activities_plan_cubit.dart';
import 'package:moean/features/activities_plan/presentation/widgets/activities_domain_order_list.dart';

/// «المجالات»: one column each, in the order they are picked; drag to reorder.
class ActivitiesDomainsSection extends StatelessWidget {
  const ActivitiesDomainsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ActivitiesPlanCubit.get(context);
    return PrimarySectionCard(
      icon: Icons.category_outlined,
      title: appTranslation().get('activities_plan_field_domains'),
      child: BlocBuilder<ActivitiesPlanCubit, ActivitiesPlanState>(
        buildWhen: (previous, current) =>
            previous.domains != current.domains || previous.catalogue != current.catalogue,
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              appTranslation().get('activities_plan_domains_hint'),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
            verticalSpace10,
            PrimaryChoiceChips(
              options: state.catalogue.domains,
              labelOf: (domain) => domain.label,
              isSelected: (domain) => state.domains.contains(domain.key),
              onTap: (domain) => cubit.toggleDomain(domain.key),
            ),
            if (state.domains.length > 1) ...[
              verticalSpace16,
              Text(
                appTranslation().get('activities_plan_columns_order'),
                style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
              ),
              verticalSpace8,
              ActivitiesDomainOrderList(
                labels: [for (final key in state.domains) state.catalogue.domainLabel(key)],
                onReorder: cubit.reorderDomain,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/tahsili/data/models/tahsili_models.dart';
import 'package:moean/features/tahsili/presentation/cubit/tahsili_cubit.dart';
import 'package:moean/features/tahsili/presentation/widgets/tahsili_domain_checkbox_tile.dart';

class TahsiliDomainsSelector extends StatelessWidget {
  final List<TahsiliDomainOption> domains;
  final Set<String> selectedDomainIds;

  const TahsiliDomainsSelector({
    super.key,
    required this.domains,
    required this.selectedDomainIds,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = TahsiliCubit.get(context);
    final allSelected = domains.isNotEmpty && selectedDomainIds.length == domains.length;

    return PrimarySectionCard(
      icon: Icons.checklist_rtl_rounded,
      title: appTranslation().get('tahsili_choose_domains'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedDomainIds.length} / ${domains.length}',
                style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
              ),
              TextButton(
                onPressed: cubit.toggleSelectAllDomains,
                child: Text(
                  allSelected
                      ? appTranslation().get('outcomes_map_clear_all')
                      : appTranslation().get('tahsili_all_domains'),
                  style: TextStylesManager.bold12.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
            ],
          ),
          verticalSpace8,
          for (var i = 0; i < domains.length; i++) ...[
            TahsiliDomainCheckboxTile(
              domain: domains[i],
              isSelected: selectedDomainIds.contains(domains[i].id),
              onChanged: (_) => cubit.toggleDomain(domains[i].id),
            ),
            if (i < domains.length - 1) verticalSpace8,
          ],
        ],
      ),
    );
  }
}

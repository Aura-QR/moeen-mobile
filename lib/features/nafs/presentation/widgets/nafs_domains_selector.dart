import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/primary/primary_section_card.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/nafs/data/models/nafs_models.dart';
import 'package:moean/features/nafs/presentation/cubit/nafs_cubit.dart';
import 'package:moean/features/nafs/presentation/widgets/nafs_domain_checkbox_tile.dart';

class NafsDomainsSelector extends StatelessWidget {
  final List<NafsDomainOption> domains;
  final Set<String> selectedDomainIds;

  const NafsDomainsSelector({
    super.key,
    required this.domains,
    required this.selectedDomainIds,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = NafsCubit.get(context);

    return PrimarySectionCard(
      icon: Icons.checklist_rounded,
      title: appTranslation().get('nafs_choose_domains'),
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
                onPressed: domains.isEmpty ? null : cubit.toggleSelectAllDomains,
                child: Text(
                  appTranslation().get('nafs_all_domains'),
                  style: TextStylesManager.medium12.copyWith(color: ColorsManager.primaryColor),
                ),
              ),
            ],
          ),
          verticalSpace4,
          for (final domain in domains)
            NafsDomainCheckboxTile(
              key: ValueKey(domain.id),
              domain: domain,
              isSelected: selectedDomainIds.contains(domain.id),
              onChanged: (_) => cubit.toggleDomain(domain.id),
            ),
        ],
      ),
    );
  }
}

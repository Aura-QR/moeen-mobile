import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/lab/presentation/cubit/admin_lab_cubit.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_experiment_card.dart';
import 'package:moean/features/lab/presentation/widgets/lab_filter_pill.dart';

class AdminLabExperimentsTab extends StatelessWidget {
  const AdminLabExperimentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminLabCubit.get(context);

    return BlocBuilder<AdminLabCubit, AdminLabState>(
      buildWhen: (prev, curr) =>
          prev.experiments != curr.experiments ||
          prev.isLoadingExperiments != curr.isLoadingExperiments ||
          prev.experimentFilter != curr.experimentFilter,
      builder: (context, state) {
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  LabFilterPill(
                    label: appTranslation().get('admin_lab_filter_all'),
                    isSelected: state.experimentFilter == null,
                    onTap: () => cubit.setExperimentFilter(null),
                  ),
                  horizontalSpace8,
                  LabFilterPill(
                    label: appTranslation().get('admin_lab_filter_community'),
                    isSelected: state.experimentFilter == 'community',
                    onTap: () => cubit.setExperimentFilter('community'),
                  ),
                  horizontalSpace8,
                  LabFilterPill(
                    label: appTranslation().get('admin_lab_filter_hidden'),
                    isSelected: state.experimentFilter == 'hidden',
                    onTap: () => cubit.setExperimentFilter('hidden'),
                  ),
                  horizontalSpace8,
                  LabFilterPill(
                    label: appTranslation().get('admin_lab_filter_reports'),
                    isSelected: state.experimentFilter == 'reports',
                    onTap: () => cubit.setExperimentFilter('reports'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ConditionalBuilder(
                loadingState: state.isLoadingExperiments,
                emptyState: state.experiments.isEmpty,
                emptyBuilder: (context) => Center(
                  child: Text(
                    appTranslation().get('admin_lab_no_experiments'),
                    style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
                loadingBuilder: (context) => Center(
                  child: CircularProgressIndicator(color: ColorsManager.primaryColor),
                ),
                successBuilder: (context) => RefreshIndicator(
                  color: ColorsManager.primaryColor,
                  onRefresh: cubit.fetchExperiments,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.experiments.length,
                    separatorBuilder: (context, index) => verticalSpace12,
                    itemBuilder: (context, index) => AdminExperimentCard(
                      experiment: state.experiments[index],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

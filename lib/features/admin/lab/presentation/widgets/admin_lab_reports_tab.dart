import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/lab/presentation/cubit/admin_lab_cubit.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_report_card.dart';
import 'package:moean/features/lab/presentation/widgets/lab_filter_pill.dart';

class AdminLabReportsTab extends StatelessWidget {
  const AdminLabReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminLabCubit.get(context);

    return BlocBuilder<AdminLabCubit, AdminLabState>(
      buildWhen: (prev, curr) =>
          prev.reports != curr.reports ||
          prev.isLoadingReports != curr.isLoadingReports ||
          prev.reportFilter != curr.reportFilter,
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
                    isSelected: state.reportFilter == null,
                    onTap: () => cubit.setReportFilter(null),
                  ),
                  horizontalSpace8,
                  LabFilterPill(
                    label: appTranslation().get('admin_lab_status_open'),
                    isSelected: state.reportFilter == 'open',
                    onTap: () => cubit.setReportFilter('open'),
                  ),
                  horizontalSpace8,
                  LabFilterPill(
                    label: appTranslation().get('admin_lab_status_done'),
                    isSelected: state.reportFilter == 'done',
                    onTap: () => cubit.setReportFilter('done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ConditionalBuilder(
                loadingState: state.isLoadingReports,
                emptyState: state.reports.isEmpty,
                emptyBuilder: (context) => Center(
                  child: Text(
                    appTranslation().get('admin_lab_no_reports'),
                    style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
                loadingBuilder: (context) => Center(
                  child: CircularProgressIndicator(color: ColorsManager.primaryColor),
                ),
                successBuilder: (context) => RefreshIndicator(
                  color: ColorsManager.primaryColor,
                  onRefresh: cubit.fetchReports,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.reports.length,
                    separatorBuilder: (context, index) => verticalSpace12,
                    itemBuilder: (context, index) => AdminReportCard(
                      report: state.reports[index],
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

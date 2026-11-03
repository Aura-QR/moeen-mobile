import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/conditional_builder.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/lab/presentation/cubit/admin_lab_cubit.dart';
import 'package:moean/features/admin/lab/presentation/widgets/admin_request_card.dart';
import 'package:moean/features/lab/presentation/widgets/lab_filter_pill.dart';

class AdminLabRequestsTab extends StatelessWidget {
  const AdminLabRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = AdminLabCubit.get(context);

    return BlocBuilder<AdminLabCubit, AdminLabState>(
      buildWhen: (prev, curr) =>
          prev.requests != curr.requests ||
          prev.isLoadingRequests != curr.isLoadingRequests ||
          prev.requestFilter != curr.requestFilter,
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
                    isSelected: state.requestFilter == null,
                    onTap: () => cubit.setRequestFilter(null),
                  ),
                  horizontalSpace8,
                  LabFilterPill(
                    label: appTranslation().get('admin_lab_status_open'),
                    isSelected: state.requestFilter == 'open',
                    onTap: () => cubit.setRequestFilter('open'),
                  ),
                  horizontalSpace8,
                  LabFilterPill(
                    label: appTranslation().get('admin_lab_status_done'),
                    isSelected: state.requestFilter == 'done',
                    onTap: () => cubit.setRequestFilter('done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ConditionalBuilder(
                loadingState: state.isLoadingRequests,
                emptyState: state.requests.isEmpty,
                emptyBuilder: (context) => Center(
                  child: Text(
                    appTranslation().get('admin_lab_no_requests'),
                    style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText),
                  ),
                ),
                loadingBuilder: (context) => Center(
                  child: CircularProgressIndicator(color: ColorsManager.primaryColor),
                ),
                successBuilder: (context) => RefreshIndicator(
                  color: ColorsManager.primaryColor,
                  onRefresh: cubit.fetchRequests,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.requests.length,
                    separatorBuilder: (context, index) => verticalSpace12,
                    itemBuilder: (context, index) => AdminRequestCard(
                      request: state.requests[index],
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

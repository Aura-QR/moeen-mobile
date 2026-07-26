import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/teachers/presentation/cubit/admin_teachers_cubit.dart';
import 'package:moean/features/admin/teachers/presentation/cubit/admin_teachers_state.dart';

class AdminStatsCardsWidget extends StatelessWidget {
  const AdminStatsCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminTeachersCubit, AdminTeachersState>(
      builder: (context, state) {
        final cubit = AdminTeachersCubit.get(context);
        final total = cubit.paginationModel?.total ?? 0;
        
        // Since we don't have a dedicated stats API, we'll calculate from loaded data 
        // or display the total for the first card as an example.
        final activeCount = cubit.teachersList.where((t) => t.active).length;
        final suspendedCount = cubit.teachersList.where((t) => !t.active).length;
        final subscribedCount = cubit.teachersList.where((t) => t.subscription?.slug != 'free').length;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 2 : 2.5,
              children: [
                _buildStatCard(
                  title: appTranslation().get('admin_total_teachers'),
                  count: total,
                  icon: Icons.people_outline,
                  
                  color: Colors.red,
                  bgColor: Colors.red.withValues(alpha: 0.1),
                ),
                _buildStatCard(
                  title: appTranslation().get('admin_active_teachers'),
                  count: activeCount, // Showing current page stats for demo
                  icon: Icons.person_outline,
                  
                  color: Colors.purple,
                  bgColor: Colors.purple.withValues(alpha: 0.1),
                ),
                _buildStatCard(
                  title: appTranslation().get('admin_suspended_accounts'),
                  count: suspendedCount, // Showing current page stats for demo
                  icon: Icons.person_off_outlined,
                  color: ColorsManager.primaryColor,
                  bgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                ),
                _buildStatCard(
                  title: appTranslation().get('admin_subscribed_plans'),
                  count: subscribedCount, // Showing current page stats for demo
                  icon: Icons.bolt_outlined,
                  color: Colors.green,
                  bgColor: Colors.green.withValues(alpha: 0.1),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count.toString(),
                  style: TextStylesManager.bold20.copyWith(color: color),
                ),
                verticalSpace4,
                Text(
                  title,
                  style: TextStylesManager.medium12.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(icon, color: color, size: 28),
        ],
      ),
    );
  }
}

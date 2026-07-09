import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_cubit.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_state.dart';

class AdminContactStatsWidget extends StatelessWidget {
  const AdminContactStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminContactCubit, AdminContactState>(
      buildWhen: (previous, current) => current is AdminContactStatsLoading || current is AdminContactStatsLoaded || current is AdminContactStatsError,
      builder: (context, state) {
        if (state is AdminContactStatsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AdminContactStatsLoaded) {
          final stats = state.stats;
          final total = stats['total'] ?? 0;
          final byStatus = stats['by_status'] ?? {};
          final resolved = byStatus['resolved'] ?? 0;
          final inProgress = byStatus['in_progress'] ?? 0;
          final pending = byStatus['pending'] ?? 0;
          final closed = byStatus['closed'] ?? 0;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                StatCardWidget(
                  title: appTranslation().get('total_tickets') ,
                  value: total.toString(),
                  icon: Icons.chat_bubble_outline,
                  color: ColorsManager.primaryColor,
                  bgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                ),
                horizontalSpace12,
                StatCardWidget(
                  title: appTranslation().get('resolved'),
                  value: resolved.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                  bgColor: Colors.green.withValues(alpha: 0.1),
                ),
                horizontalSpace12,
                StatCardWidget(
                  title: appTranslation().get('in_progress'),
                  value: inProgress.toString(),
                  icon: Icons.access_time,
                  color: Colors.blue,
                  bgColor: Colors.blue.withValues(alpha: 0.1),
                ),
                horizontalSpace12,
                StatCardWidget(
                  title: appTranslation().get('pending'),
                  value: pending.toString(),
                  icon: Icons.hourglass_empty,
                  color: Colors.orange,
                  bgColor: Colors.orange.withValues(alpha: 0.1),
                ),
                horizontalSpace12,
                StatCardWidget(
                  title: appTranslation().get('closed'),
                  value: closed.toString(),
                  icon: Icons.cancel_outlined,
                  color: Colors.grey,
                  bgColor: Colors.grey.withValues(alpha: 0.1),
                ),
              ],
            ),
          );
        } else if (state is AdminContactStatsError) {
          return Center(child: Text(state.error, style: TextStylesManager.bold14.copyWith(color: Colors.red)));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class StatCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color),
              Text(
                value,
                style: TextStylesManager.bold24.copyWith(color: ColorsManager.mainText),
              ),
            ],
          ),
          verticalSpace16,
          Text(
            title,
            style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
          ),
        ],
      ),
    );
  }
}

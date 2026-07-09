import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_cubit.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_state.dart';

class AdminContactListWidget extends StatelessWidget {
  const AdminContactListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminContactCubit, AdminContactState>(
      buildWhen: (previous, current) => current is AdminContactTicketsLoading || current is AdminContactTicketsLoaded || current is AdminContactTicketsError,
      builder: (context, state) {
        if (state is AdminContactTicketsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AdminContactTicketsLoaded) {
          final tickets = state.tickets;
          if (tickets.isEmpty) {
            return Center(
              child: Text(
                appTranslation().get('no_tickets') ?? 'لا توجد تذاكر',
                style: TextStylesManager.bold16.copyWith(color: ColorsManager.secondaryText),
              ),
            );
          }
          return ListView.separated(
            itemCount: tickets.length,
            separatorBuilder: (context, index) => verticalSpace12,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return TicketListItemWidget(ticket: ticket);
            },
          );
        } else if (state is AdminContactTicketsError) {
          return Center(child: Text(state.error, style: TextStylesManager.bold14.copyWith(color: Colors.red)));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class TicketListItemWidget extends StatelessWidget {
  final dynamic ticket;

  const TicketListItemWidget({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final status = ticket['status'] ?? 'pending';
    final statusLabel = ticket['status_label'] ?? 'قيد الانتظار';
    final name = ticket['name'] ?? 'بدون اسم';
    final email = ticket['email'] ?? '';
    final typeLabel = ticket['type_label'] ?? '';
    final createdAt = ticket['created_at'] != null ? DateTime.tryParse(ticket['created_at']) : null;
    
    Color statusColor;
    switch (status) {
      case 'resolved':
        statusColor = Colors.green;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.adminTicketDetails, arguments: {'id': ticket['id']}).then((result) {
          if (result == true) {
            if (context.mounted) {
              AdminContactCubit.get(context).getStats();
              AdminContactCubit.get(context).getTickets();
            }
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsManager.surfacePrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsManager.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: statusColor),
                    horizontalSpace6,
                    Text(
                      statusLabel,
                      style: TextStylesManager.bold12.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace4,
          Text(
            email,
            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
          ),
          verticalSpace12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorsManager.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  typeLabel,
                  style: TextStylesManager.bold12.copyWith(color: ColorsManager.mainText),
                ),
              ),
              if (createdAt != null)
                Text(
                  '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}',
                  style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

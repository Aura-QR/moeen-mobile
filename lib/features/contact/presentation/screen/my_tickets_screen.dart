import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/core/utils/extensions/context_extension.dart';
import 'package:moean/features/contact/presentation/cubit/contact_cubit.dart';
import 'package:moean/features/contact/presentation/cubit/contact_state.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  @override
  void initState() {
    super.initState();
    ContactCubit.get(context).getMyTickets();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactCubit, ContactState>(
      buildWhen: (previous, current) => current is ContactMyTicketsLoading || current is ContactMyTicketsLoaded || current is ContactMyTicketsError,
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: ColorsManager.background,
            appBar: AppBar(
              backgroundColor: ColorsManager.background,
              elevation: 0,
              centerTitle: true,
              title: Text(
                appTranslation().get('my_requests_conversations'),
                style: TextStylesManager.bold18.copyWith(color: ColorsManager.mainText),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: ColorsManager.mainText),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon:  Icon(Icons.refresh, color: ColorsManager.primaryColor),
                  onPressed: () => ContactCubit.get(context).getMyTickets(),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildTicketsList(state),
                    ),
                    verticalSpace16,
                    PrimaryElevatedButton(
                      text: appTranslation().get('new_request'),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.createTicket).then((_) {
                          if (context.mounted) {
                            ContactCubit.get(context).getMyTickets();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketsList(ContactState state) {
    if (state is ContactMyTicketsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ContactMyTicketsError) {
      return Center(child: Text(state.error, style: TextStylesManager.bold14.copyWith(color: Colors.red)));
    } else if (state is ContactMyTicketsLoaded) {
      final tickets = state.tickets;
      if (tickets.isEmpty) {
        return Center(
          child: Text(
            appTranslation().get('no_tickets'),
            style: TextStylesManager.bold16.copyWith(color: Colors.grey),
          ),
        );
      }
      return ListView.separated(
        itemCount: tickets.length,
        separatorBuilder: (context, index) => verticalSpace16,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return TeacherTicketItemWidget(ticket: ticket);
        },
      );
    }
    return const SizedBox.shrink();
  }
}

class TeacherTicketItemWidget extends StatelessWidget {
  final dynamic ticket;

  const TeacherTicketItemWidget({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final status = ticket['status'] ?? 'pending';
    final statusLabel = ticket['status_label'] ?? appTranslation().get('pending');
    final typeLabel = ticket['type_label'] ?? '';
    final message = ticket['message'] ?? '';
    final repliesCount = ticket['replies_count'] ?? 0;
    final createdAt = ticket['created_at'] != null ? DateTime.tryParse(ticket['created_at']) : null;
    final ticketId = ticket['id'] != null ? '#${ticket['id']}' : '';

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
        Navigator.pushNamed(context, Routes.ticketDetails, arguments: {'id': ticket['id']}).then((_) {
          if (context.mounted) {
            ContactCubit.get(context).getMyTickets();
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
                Expanded(
                  child: Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                horizontalSpace8,
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
              '$ticketId • $repliesCount ${appTranslation().get('replies') ?? 'رد'}',
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

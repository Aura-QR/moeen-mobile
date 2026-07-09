import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_cubit.dart';

class AdminTicketChatHistory extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const AdminTicketChatHistory({super.key, required this.ticket});

  @override
  State<AdminTicketChatHistory> createState() => _AdminTicketChatHistoryState();
}

class _AdminTicketChatHistoryState extends State<AdminTicketChatHistory> {
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopCard(context),
        verticalSpace24,
        _buildChatCard(context),
      ],
    );
  }

  Widget _buildTopCard(BuildContext context) {
    final status = widget.ticket['status'] ?? 'pending';
    final statusLabel = widget.ticket['status_label'] ?? appTranslation().get('pending');
    final user = widget.ticket['user'];
    final name = widget.ticket['name'] ?? user?['name'] ?? '';
    final email = widget.ticket['email'] ?? user?['email'] ?? '';
    final phone = widget.ticket['phone'] ?? user?['phone'] ?? '';
    final typeLabel = widget.ticket['type_label'] ?? '';
    final message = widget.ticket['message'] ?? '';
    final createdAt = _formatDate(widget.ticket['created_at']);

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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      name,
                      style: TextStylesManager.bold18.copyWith(color: ColorsManager.primaryColor),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 14, color: statusColor),
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
              ),
              IconButton(
                onPressed: () {
                  _showDeleteDialog(context, widget.ticket['id']);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
          verticalSpace16,
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (email.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email_outlined, size: 16, color: ColorsManager.secondaryText),
                    horizontalSpace8,
                    Text(email, style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText)),
                  ],
                ),
              if (phone.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: ColorsManager.secondaryText),
                    horizontalSpace8,
                    Text(phone, style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText)),
                  ],
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorsManager.statusSuccess.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(typeLabel, style: TextStylesManager.bold12.copyWith(color: ColorsManager.statusSuccess)),
              ),
              Text(createdAt, style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
            ],
          ),
          verticalSpace24,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsManager.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appTranslation().get('original_message'),
                  style: TextStylesManager.bold12.copyWith(color: ColorsManager.secondaryText),
                ),
                verticalSpace12,
                Text(
                  message,
                  style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(BuildContext context) {
    final replies = (widget.ticket['replies'] as List<dynamic>?) ?? [];
    
    return Container(
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                 Icon(Icons.chat_bubble_outline, color: ColorsManager.primaryColor),
                horizontalSpace12,
                Text(
                  '${appTranslation().get('chat_history')} (${replies.length})',
                  style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: replies.length,
                separatorBuilder: (context, index) => verticalSpace24,
                itemBuilder: (context, index) {
                  final reply = replies[index];
                  final isClient = reply['sender_type'] == 'client';
                  final senderName = reply['sender_name'] ?? (isClient ? appTranslation().get('client') : appTranslation().get('admin'));
                  final date = _formatDateWithTime(reply['created_at']);
                  final body = reply['body'] ?? '';

                  return Column(
                    crossAxisAlignment: isClient ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: isClient ? MainAxisAlignment.start : MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              senderName,
                              style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          horizontalSpace8,
                          Text(
                            date,
                            style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
                          ),
                        ],
                      ),
                      verticalSpace8,
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isClient ? ColorsManager.primaryColor.withValues(alpha: 0.1) : ColorsManager.background,
                          borderRadius: BorderRadius.circular(12).copyWith(
                            bottomRight: isClient ? Radius.zero : const Radius.circular(12),
                            bottomLeft: isClient ? const Radius.circular(12) : Radius.zero,
                          ),
                        ),
                        child: Text(
                          body,
                          style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryTextField(
                    controller: _replyController,
                    hint: appTranslation().get('write_your_reply_here'),
                  ),
                ),
                horizontalSpace16,
                
                PrimaryElevatedButton(
                  width: 80,
                  text: '',
                  icon: const Icon(Icons.send_sharp, color: Colors.white),
                  onPressed: () {
                    if (_replyController.text.trim().isNotEmpty) {
                      AdminContactCubit.get(context).replyToTicket(
                        id: widget.ticket['id'],
                        body: _replyController.text.trim(),
                      );
                      _replyController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: ColorsManager.surfacePrimary,
            title: Text(appTranslation().get('delete_ticket'), style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText)),
            content: Text(appTranslation().get('delete_ticket_confirm'), style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(appTranslation().get('cancel'), style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  AdminContactCubit.get(context).deleteTicket(id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(appTranslation().get('delete'), style: TextStylesManager.bold14.copyWith(color: ColorsManager.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    return '${dt.day} ${_getMonthName(dt.month)} ${dt.year}';
  }

  String _formatDateWithTime(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    final amPm = dt.hour >= 12 ? 'م' : 'ص';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${_getMonthName(dt.month)} ${dt.year} $hour:$minute $amPm';
  }

  String _getMonthName(int month) {
    const months = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    if (month >= 1 && month <= 12) return months[month];
    return month.toString();
  }
}

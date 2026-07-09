import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/contact/presentation/cubit/contact_cubit.dart';

class TicketChatHistory extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const TicketChatHistory({super.key, required this.ticket});

  @override
  State<TicketChatHistory> createState() => _TicketChatHistoryState();
}

class _TicketChatHistoryState extends State<TicketChatHistory> {
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
    final statusLabel = widget.ticket['status_label'] ?? 'تم الحل';
    final typeLabel = widget.ticket['type_label'] ?? 'اقتراح ميزة';
    final message = widget.ticket['message'] ?? '';
    final createdAt = _formatDateDetails(widget.ticket['created_at']);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ColorsManager.isDark ? ColorsManager.surfacePrimary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.isDark ? Colors.transparent : Colors.grey.shade200),
        boxShadow: [
          if (!ColorsManager.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appTranslation().get('ticket_summary') ?? 'ملخص التذكرة',
                style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStylesManager.bold12.copyWith(color: Colors.green.shade700),
                ),
              ),
            ],
          ),
          verticalSpace16,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appTranslation().get('date') ?? 'التاريخ', style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
                  verticalSpace4,
                  Text(createdAt, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(typeLabel, style: TextStylesManager.bold12.copyWith(color: Colors.green.shade700)),
              ),
            ],
          ),
          verticalSpace24,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsManager.isDark ? Colors.transparent : Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appTranslation().get('original_message') ?? 'نص الرسالة الأصلي',
                        style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText),
                      ),
                    ),
                  ],
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
        color: ColorsManager.isDark ? ColorsManager.surfacePrimary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsManager.isDark ? Colors.transparent : Colors.grey.shade200),
        boxShadow: [
          if (!ColorsManager.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appTranslation().get('original_message') ?? 'نص الرسالة الأصلي',
                    style: TextStylesManager.bold16.copyWith(color: ColorsManager.mainText),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${appTranslation().get('chat_history') ?? 'المحادثة'} (${replies.length})',
                      style: TextStylesManager.bold16.copyWith(color: Colors.teal),
                    ),
                    horizontalSpace8,
                    const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ColorsManager.isDark ? Colors.grey.shade800 : Colors.grey.shade200),
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
                  final body = reply['body'] ?? '';
                  final rawDate = reply['created_at'];

                  if (isClient) {
                    return _buildClientMessage(body, rawDate);
                  } else {
                    final senderNameAr = reply['sender_name'] ?? 'مدير النظام';
                    final senderNameEn = 'System Admin'; // Placeholder
                    return _buildAdminMessage(senderNameAr, senderNameEn, body, rawDate);
                  }
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    if (_replyController.text.trim().isNotEmpty) {
                      ContactCubit.get(context).replyToTicket(
                        id: widget.ticket['id'],
                        body: _replyController.text.trim(),
                      );
                      _replyController.clear();
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.send_outlined, color: Colors.white, size: 20),
                        
                      ],
                    ),
                  ),
                ),
                horizontalSpace16,
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    maxLines: 5,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: appTranslation().get('write_your_reply_here') ?? 'اكتب ردك هنا...',
                      hintStyle: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientMessage(String body, String? rawDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Right aligned in RTL
      children: [
        Text(
          '${appTranslation().get('chat_date') ?? 'تاريخ الدردشة'} / ${_formatDateShort(rawDate)}',
          style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
        ),
        verticalSpace8,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorsManager.isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16).copyWith(
              topRight: const Radius.circular(4), // Make the bubble point slightly
            ),
          ),
          child: Text(
            body,
            style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminMessage(String senderNameAr, String senderNameEn, String body, String? rawDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Left aligned in RTL
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _formatDateShort(rawDate),
              style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText),
            ),
            horizontalSpace12,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(senderNameAr, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
                Text(senderNameEn, style: TextStylesManager.regular12.copyWith(color: ColorsManager.secondaryText)),
              ],
            ),
            horizontalSpace12,
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueGrey,
              child: Text(
                senderNameEn.isNotEmpty ? senderNameEn[0].toUpperCase() : 'A',
                style: TextStylesManager.bold16.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        verticalSpace8,
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorsManager.isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(16).copyWith(
              topLeft: const Radius.circular(4),
            ),
          ),
          child: Text(
            body,
            style: TextStylesManager.regular14.copyWith(color: ColorsManager.mainText),
          ),
        ),
      ],
    );
  }

  String _formatDateDetails(String? dateStr) {
    if (dateStr == null) return 'July 9, 2026';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return 'July 9, 2026';
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatDateShort(String? dateStr) {
    if (dateStr == null) return 'يوليو / 10:02 AM ص';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return 'يوليو / 10:02 AM ص';
    
    final amPm = dt.hour >= 12 ? 'PM م' : 'AM ص';
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    
    const months = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    
    return '${dt.day} ${months[dt.month]} / $hour:$minute $amPm';
  }
}

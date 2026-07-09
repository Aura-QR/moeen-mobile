import 'package:flutter/material.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/primary/primary_elevated_button.dart';
import 'package:moean/core/utils/constants/primary/primary_text_field.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/contact/presentation/cubit/admin_contact_cubit.dart';

class AdminTicketInfoCard extends StatefulWidget {
  final Map<String, dynamic> ticket;

  const AdminTicketInfoCard({super.key, required this.ticket});

  @override
  State<AdminTicketInfoCard> createState() => _AdminTicketInfoCardState();
}

class _AdminTicketInfoCardState extends State<AdminTicketInfoCard> {
  late String selectedStatus;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.ticket['status'] ?? 'pending';
    notesController = TextEditingController(text: widget.ticket['admin_notes'] ?? '');
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildManagementCard(context),
        verticalSpace24,
        _buildDetailsCard(context),
      ],
    );
  }

  Widget _buildManagementCard(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appTranslation().get('ticket_management'),
                style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor),
              ),
               Icon(Icons.filter_alt_outlined, color: ColorsManager.primaryColor),
            ],
          ),
          verticalSpace16,
          Text(
            appTranslation().get('status'),
            style: TextStylesManager.regular12.copyWith(color: ColorsManager.mainText),
          ),
          verticalSpace8,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: ColorsManager.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'pending', child: Text(appTranslation().get('pending'))),
                  DropdownMenuItem(value: 'in_progress', child: Text(appTranslation().get('in_progress'))),
                  DropdownMenuItem(value: 'resolved', child: Text(appTranslation().get('resolved'))),
                  DropdownMenuItem(value: 'closed', child: Text(appTranslation().get('closed'))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStatus = value;
                    });
                  }
                },
              ),
            ),
          ),
          verticalSpace16,
          Row(
            children: [
              Icon(Icons.note_alt_outlined, size: 16, color: ColorsManager.secondaryText),
              horizontalSpace8,
              Text(
                appTranslation().get('internal_notes'),
                style: TextStylesManager.regular12.copyWith(color: ColorsManager.mainText),
              ),
            ],
          ),
          verticalSpace8,
          PrimaryTextField(
            controller: notesController,
            hint: appTranslation().get('add_internal_notes'),
            maxLines: 4,
          ),
          verticalSpace24,
          PrimaryElevatedButton(
            text: appTranslation().get('save_changes'),
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              AdminContactCubit.get(context).updateTicket(
                id: widget.ticket['id'],
                status: selectedStatus,
                adminNotes: notesController.text,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
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
          Text(
            appTranslation().get('ticket_details'),
            style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor),
          ),
          verticalSpace24,
          _buildDetailRow(appTranslation().get('id'), '#${widget.ticket['id']}'),
          const Divider(),
          _buildDetailRow(appTranslation().get('type'), widget.ticket['type_label'] ?? ''),
          const Divider(),
          _buildDetailRow(appTranslation().get('replies'), '${widget.ticket['replies_count'] ?? 0} ${appTranslation().get('reply')}'),
          const Divider(),
          _buildDetailRow(appTranslation().get('unread_admin'), '${widget.ticket['unread_by_admin_count'] ?? 0}'),
          const Divider(),
          _buildDetailRow(appTranslation().get('unread_client'), '${widget.ticket['unread_by_client_count'] ?? 0}'),
          const Divider(),
          _buildDetailRow(appTranslation().get('created_at'), _formatDate(widget.ticket['created_at'])),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStylesManager.regular14.copyWith(color: ColorsManager.secondaryText)),
          Text(value, style: TextStylesManager.bold14.copyWith(color: ColorsManager.mainText)),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

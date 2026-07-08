import 'package:flutter/material.dart';
import 'package:moean/core/models/admin_teacher_model.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/teachers/presentation/widgets/admin_teacher_action_dialogs.dart';

class AdminTeachersTableWidget extends StatelessWidget {
  final List<AdminTeacherModel> teachers;
  final ScrollController scrollController;

  const AdminTeachersTableWidget({
    super.key,
    required this.teachers,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (teachers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('لا توجد بيانات'),
        ),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.withValues(alpha: 0.1)),
          dataRowMaxHeight: 60,
          columns: [
            DataColumn(label: Text(appTranslation().get('admin_teacher'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_email'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_phone'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_plan'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_status'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_join_date'), style: TextStylesManager.bold14)),
            DataColumn(label: Text(appTranslation().get('admin_actions'), style: TextStylesManager.bold14)),
          ],
          rows: teachers.map((teacher) => _buildDataRow(context, teacher)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, AdminTeacherModel teacher) {
    final avatarLetter = teacher.user.name.isNotEmpty ? teacher.user.name.substring(0, 1) : '?';
    
    // Format date roughly (could use intl package for proper formatting)
    final dateStr = teacher.user.createdAt != null 
        ? teacher.user.createdAt!.split('T').first 
        : '-';

    return DataRow(
      cells: [
        // Teacher (Avatar + Name)
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.2),
                child: Text(avatarLetter, style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.bold)),
              ),
              horizontalSpace8,
              Text(teacher.user.name, style: TextStylesManager.medium14),
            ],
          ),
        ),
        // Email
        DataCell(Text(teacher.user.email, style: TextStylesManager.medium14)),
        // Phone
        DataCell(Text(teacher.user.phone ?? '-', style: TextStylesManager.medium14)),
        // Plan
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              teacher.subscription?.name ?? appTranslation().get('admin_plan_free'),
              style: TextStylesManager.medium12.copyWith(color: ColorsManager.primaryColor),
            ),
          ),
        ),
        // Status
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: teacher.active ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: teacher.active ? Colors.green : Colors.red),
                horizontalSpace4,
                Text(
                  teacher.active ? appTranslation().get('admin_active') : appTranslation().get('admin_suspended'),
                  style: TextStylesManager.medium12.copyWith(
                    color: teacher.active ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Join Date
        DataCell(Text(dateStr, style: TextStylesManager.medium14)),
        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.purple),
                onPressed: () => showEditTeacherDialog(context, teacher),
                tooltip: appTranslation().get('admin_edit'),
              ),
              IconButton(
                icon: const Icon(Icons.vpn_key_outlined, size: 20, color: Colors.orange),
                onPressed: () => showResetPasswordDialog(context, teacher),
                tooltip: appTranslation().get('admin_reset_password'),
              ),
              IconButton(
                icon: const Icon(Icons.power_settings_new, size: 20, color: Colors.red),
                onPressed: () => showToggleStatusDialog(context, teacher),
                tooltip: teacher.active ? appTranslation().get('admin_suspend') : appTranslation().get('admin_activate'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                onPressed: () => showDeleteTeacherDialog(context, teacher),
                tooltip: appTranslation().get('admin_delete'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:moean/core/models/admin_teacher_model.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/teachers/presentation/widgets/admin_teacher_action_dialogs.dart';

class AdminTeachersTableWidget extends StatefulWidget {
  final List<AdminTeacherModel> teachers;
  final ScrollController scrollController;

  const AdminTeachersTableWidget({
    super.key,
    required this.teachers,
    required this.scrollController,
  });

  @override
  State<AdminTeachersTableWidget> createState() => _AdminTeachersTableWidgetState();
}

class _AdminTeachersTableWidgetState extends State<AdminTeachersTableWidget> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.teachers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('لا توجد بيانات'),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Adjusted dark mode header color for better contrast
    final headerColor = isDark ? const Color(0xFF2C2C2E) : Colors.grey.withValues(alpha: 0.1);
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey.withValues(alpha: 0.2);

    const double colTeacher = 220;
    const double colEmail = 220;
    const double colPhone = 140;
    const double colPlan = 120;
    const double colStatus = 120;
    const double colDate = 120;
    const double colActions = 240;
    const double totalWidth = colTeacher + colEmail + colPhone + colPlan + colStatus + colDate + colActions;

    return Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            children: [
              // Header Row
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: headerColor,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    _buildHeaderCell(appTranslation().get('admin_teacher'), colTeacher),
                    _buildHeaderCell(appTranslation().get('admin_email'), colEmail),
                    _buildHeaderCell(appTranslation().get('admin_phone'), colPhone),
                    _buildHeaderCell(appTranslation().get('admin_plan'), colPlan),
                    _buildHeaderCell(appTranslation().get('admin_status'), colStatus),
                    _buildHeaderCell(appTranslation().get('admin_join_date'), colDate),
                    _buildHeaderCell(appTranslation().get('admin_actions'), colActions),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: ListView.separated(
                  controller: widget.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: widget.teachers.length,
                  separatorBuilder: (context, index) => Divider(color: borderColor, height: 1),
                  itemBuilder: (context, index) {
                    return _buildDataRow(context, widget.teachers[index], colTeacher, colEmail, colPhone, colPlan, colStatus, colDate, colActions);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(text, style: TextStylesManager.bold14),
        ),
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context, 
    AdminTeacherModel teacher,
    double colTeacher,
    double colEmail,
    double colPhone,
    double colPlan,
    double colStatus,
    double colDate,
    double colActions,
  ) {
    final avatarLetter = teacher.user.name.isNotEmpty ? teacher.user.name.substring(0, 1) : '?';
    
    final dateStr = teacher.user.createdAt != null 
        ? teacher.user.createdAt!.split('T').first 
        : '-';

    return SizedBox(
      height: 60,
      child: Row(
        children: [
          // Teacher
          SizedBox(
            width: colTeacher,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.2),
                    child: Text(avatarLetter, style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.bold)),
                  ),
                  horizontalSpace8,
                  Expanded(
                    child: Text(
                      teacher.user.name, 
                      style: TextStylesManager.medium14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Email
          SizedBox(
            width: colEmail,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  teacher.user.email, 
                  style: TextStylesManager.medium14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Phone
          SizedBox(
            width: colPhone,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(teacher.user.phone ?? '-', style: TextStylesManager.medium14),
              ),
            ),
          ),
          // Plan
          SizedBox(
            width: colPlan,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
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
            ),
          ),
          // Status
          SizedBox(
            width: colStatus,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
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
            ),
          ),
          // Join Date
          SizedBox(
            width: colDate,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(dateStr, style: TextStylesManager.medium14),
              ),
            ),
          ),
          // Actions
          SizedBox(
            width: colActions,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
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
          ),
        ],
      ),
    );
  }
}


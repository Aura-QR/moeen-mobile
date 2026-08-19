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

  static const _arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];

  static String _getMonthName(int month) {
    if (month >= 1 && month <= 12) {
      return _arabicMonths[month - 1];
    }
    return '$month';
  }

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
    final headerColor = isDark ? const Color(0xFF2C2C2E) : Colors.grey.withValues(alpha: 0.1);
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey.withValues(alpha: 0.2);

    const double colTeacher = 190;
    const double colPhone = 120;
    const double colPlan = 175;
    const double colStatus = 95;
    const double colDate = 100;
    const double colActions = 140;
    const double totalWidth = colTeacher + colPhone + colPlan + colStatus + colDate + colActions;

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
                    _buildHeaderCell(appTranslation().get('admin_phone'), colPhone),
                    _buildHeaderCell(appTranslation().get('admin_plan'), colPlan, alignment: AlignmentDirectional.center),
                    _buildHeaderCell(appTranslation().get('admin_status'), colStatus, alignment: AlignmentDirectional.center),
                    _buildHeaderCell(appTranslation().get('admin_join_date'), colDate, alignment: AlignmentDirectional.center),
                    _buildHeaderCell(appTranslation().get('admin_actions'), colActions, alignment: AlignmentDirectional.center),
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
                    return _buildDataRow(context, widget.teachers[index], colTeacher, colPhone, colPlan, colStatus, colDate, colActions);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width, {AlignmentDirectional alignment = AlignmentDirectional.centerStart}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Align(
          alignment: alignment,
          child: Text(text, style: TextStylesManager.bold14),
        ),
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context, 
    AdminTeacherModel teacher,
    double colTeacher,
    double colPhone,
    double colPlan,
    double colStatus,
    double colDate,
    double colActions,
  ) {
    return SizedBox(
      height: 76,
      child: Row(
        children: [
          // Teacher Name & Email
          _buildTeacherCell(context, teacher, colTeacher),
          // Phone
          SizedBox(
            width: colPhone,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(teacher.user.phone ?? '-', style: TextStylesManager.medium14),
              ),
            ),
          ),
          // Plan & Expiry
          _buildPlanAndExpiryCell(context, teacher, colPlan),
          // Status
          SizedBox(
            width: colStatus,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: teacher.active ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 7, color: teacher.active ? Colors.green : Colors.red),
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
          _buildJoinDateCell(context, teacher.user.createdAt, colDate),
          // Actions
          _buildActionsCell(context, teacher, colActions),
        ],
      ),
    );
  }

  Widget _buildTeacherCell(BuildContext context, AdminTeacherModel teacher, double width) {
    final avatarLetter = teacher.user.name.isNotEmpty ? teacher.user.name.substring(0, 1) : '?';

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: ColorsManager.primaryColor.withValues(alpha: 0.2),
              child: Text(avatarLetter, style: TextStyle(color: ColorsManager.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            horizontalSpace8,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.user.name,
                    style: TextStylesManager.medium14,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    teacher.user.email,
                    style: TextStylesManager.regular12.copyWith(color: Colors.grey, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinDateCell(BuildContext context, String? createdAt, double width) {
    if (createdAt == null || createdAt.isEmpty) {
      return SizedBox(
        width: width,
        child: const Center(child: Text('-', style: TextStyle(color: Colors.grey))),
      );
    }
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) {
      return SizedBox(
        width: width,
        child: Center(child: Text(createdAt.split('T').first, style: TextStylesManager.medium12)),
      );
    }
    final monthName = _getMonthName(dt.month);

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${dt.day}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.1),
          ),
          Text(
            monthName,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.1),
          ),
          Text(
            '${dt.year}',
            style: const TextStyle(fontSize: 10.5, color: Colors.grey, height: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCell(BuildContext context, AdminTeacherModel teacher, double width) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionBtn(
              icon: Icons.edit_outlined,
              color: Colors.purple,
              onTap: () => showEditTeacherDialog(context, teacher),
              tooltip: appTranslation().get('admin_edit'),
            ),
            const SizedBox(width: 2),
            _buildActionBtn(
              icon: Icons.vpn_key_outlined,
              color: Colors.orange,
              onTap: () => showResetPasswordDialog(context, teacher),
              tooltip: appTranslation().get('admin_reset_password'),
            ),
            const SizedBox(width: 2),
            _buildActionBtn(
              icon: Icons.power_settings_new,
              color: Colors.red,
              onTap: () => showToggleStatusDialog(context, teacher),
              tooltip: teacher.active ? appTranslation().get('admin_suspend') : appTranslation().get('admin_activate'),
            ),
            const SizedBox(width: 2),
            _buildActionBtn(
              icon: Icons.delete_outline,
              color: Colors.redAccent,
              onTap: () => showDeleteTeacherDialog(context, teacher),
              tooltip: appTranslation().get('admin_delete'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanAndExpiryCell(BuildContext context, AdminTeacherModel teacher, double width) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isSubscribedActive = teacher.isSubscribed && !teacher.isExpired && !teacher.isFreePlan;
    final isTrialActive = teacher.isInTrial && !teacher.isExpired;
    final isTrialEnded = teacher.isTrialExpired || (teacher.isExpired && !teacher.isSubscribed);
    final isSubscribedExpired = teacher.isSubscribed && teacher.isExpired;
    final isFree = teacher.isFreePlan && !isTrialActive && !isTrialEnded && !isSubscribedActive && !isSubscribedExpired && teacher.effectiveEndsAt == null;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Pill Badge
            _buildTopPillBadge(
              context,
              teacher,
              isSubscribedActive: isSubscribedActive,
              isTrialActive: isTrialActive,
              isTrialEnded: isTrialEnded,
              isSubscribedExpired: isSubscribedExpired,
              isFree: isFree,
              isDark: isDark,
            ),
            const SizedBox(height: 4),
            // Bottom Details
            _buildExpiryDetails(
              context,
              teacher,
              isSubscribedActive: isSubscribedActive,
              isTrialActive: isTrialActive,
              isTrialEnded: isTrialEnded,
              isSubscribedExpired: isSubscribedExpired,
              isFree: isFree,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPillBadge(
    BuildContext context,
    AdminTeacherModel teacher, {
    required bool isSubscribedActive,
    required bool isTrialActive,
    required bool isTrialEnded,
    required bool isSubscribedExpired,
    required bool isFree,
    required bool isDark,
  }) {
    if (isTrialActive) {
      final bg = isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB);
      final border = isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A);
      final text = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2.5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تجربة مجانية',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: text,
                height: 1.1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.access_time_outlined, size: 12.5, color: text),
          ],
        ),
      );
    }

    if (isTrialEnded || isSubscribedExpired) {
      final bg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);
      final border = isDark ? const Color(0xFFDC2626) : const Color(0xFFFECACA);
      final text = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isTrialEnded ? 'انتهت' : 'انتهى',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: text,
                    height: 1.1,
                  ),
                ),
                Text(
                  isTrialEnded ? 'التجربة' : 'الاشتراك',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: text,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.error_outline_rounded, size: 13, color: text),
          ],
        ),
      );
    }

    if (isSubscribedActive) {
      final bg = isDark ? const Color(0xFF042F2E) : const Color(0xFFE0F2F1);
      final border = isDark ? const Color(0xFF0D9488) : const Color(0xFF99F6E4);
      final text = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E);
      final planName = teacher.subscription?.name ?? 'فصل دراسي واحد';

      final words = planName.trim().split(' ');
      Widget titleWidget;
      if (words.length >= 3) {
        titleWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${words[0]} ${words[1]}',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: text, height: 1.1),
            ),
            Text(
              words.sublist(2).join(' '),
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: text, height: 1.1),
            ),
          ],
        );
      } else if (words.length == 2) {
        titleWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              words[0],
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: text, height: 1.1),
            ),
            Text(
              words[1],
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: text, height: 1.1),
            ),
          ],
        );
      } else {
        titleWidget = Text(
          planName,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text, height: 1.1),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            titleWidget,
            const SizedBox(width: 4),
            Icon(Icons.bolt_rounded, size: 14, color: text),
          ],
        ),
      );
    }

    final bg = isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : const Color(0xFFF3F4F6);
    final border = isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB);
    final text = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        'مجاني',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _buildExpiryDetails(
    BuildContext context,
    AdminTeacherModel teacher, {
    required bool isSubscribedActive,
    required bool isTrialActive,
    required bool isTrialEnded,
    required bool isSubscribedExpired,
    required bool isFree,
    required bool isDark,
  }) {
    if (isFree || teacher.effectiveEndsAt == null) {
      return Text(
        '-',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
      );
    }

    final dt = teacher.effectiveEndsAt!;
    final monthName = _getMonthName(dt.month);
    final days = teacher.dynamicDaysRemaining;

    if (isTrialActive) {
      final boxBg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
      final boxBorder = isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A);
      final textColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E);
      final calendarColor = isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Countdown badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: boxBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: boxBorder, width: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'متبقي',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
                Text(
                  days > 2 && days <= 10 ? '$days أيام' : '$days يوم',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          // Date text + Calendar Icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تنتهي: ${dt.day}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '$monthName ${dt.year}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 3),
              Icon(Icons.calendar_today_outlined, size: 13, color: calendarColor),
            ],
          ),
        ],
      );
    }

    if (isTrialEnded || isSubscribedExpired) {
      final textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'انتهى: ${dt.day} $monthName',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.1,
                ),
              ),
              Text(
                '${dt.year}',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 3),
          Icon(Icons.calendar_today_outlined, size: 13, color: textColor),
        ],
      );
    }

    if (isSubscribedActive) {
      final boxBg = isDark ? const Color(0xFF042F2E) : const Color(0xFFCCFBF1);
      final boxBorder = isDark ? const Color(0xFF0D9488) : const Color(0xFF99F6E4);
      final textColor = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E);
      final calendarColor = isDark ? const Color(0xFF14B8A6) : const Color(0xFF0D9488);

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Countdown badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: boxBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: boxBorder, width: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$days',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
                Text(
                  'يوم',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          // Date text + Calendar Icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ينتهي: ${dt.day}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '$monthName ${dt.year}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 3),
              Icon(Icons.calendar_today_outlined, size: 13, color: calendarColor),
            ],
          ),
        ],
      );
    }

    return Text(
      '-',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
      ),
    );
  }
}



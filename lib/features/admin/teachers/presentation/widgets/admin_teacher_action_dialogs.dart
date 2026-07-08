import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moean/core/models/admin_teacher_model.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/admin/teachers/presentation/cubit/admin_teachers_cubit.dart';
import 'package:moean/core/theme/colors.dart';

void showAddTeacherDialog(BuildContext context) {
  final cubit = AdminTeachersCubit.get(context);
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  int subscriptionId = 1; // Default free

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(appTranslation().get('admin_add_teacher')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: appTranslation().get('full_name')),
              ),
              verticalSpace12,
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: appTranslation().get('admin_email')),
              ),
              verticalSpace12,
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: appTranslation().get('admin_phone')),
              ),
              verticalSpace12,
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: appTranslation().get('password')),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(appTranslation().get('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.addTeacher(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                password: passwordController.text,
                subscriptionId: subscriptionId,
              );
              Navigator.pop(dialogContext);
            },
            child: Text(appTranslation().get('admin_add_teacher')),
          ),
        ],
      );
    },
  );
}

void showEditTeacherDialog(BuildContext context, AdminTeacherModel teacher) {
  final cubit = AdminTeachersCubit.get(context);
  final nameController = TextEditingController(text: teacher.user.name);
  final phoneController = TextEditingController(text: teacher.user.phone ?? '');
  final endDateController = TextEditingController(text: teacher.subscriptionEndsAt ?? '');
  
  int? selectedPlanId = teacher.subscription?.id;
  bool isActive = teacher.active;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFECA332), // orange from screenshot
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white),
                            ),
                            horizontalSpace16,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('تعديل بيانات المعلم', style: TextStylesManager.bold18.copyWith(color: ColorsManager.primaryColor)),
                                verticalSpace4,
                                Text(teacher.user.email, style: TextStylesManager.medium14.copyWith(color: ColorsManager.secondaryText)),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    
                    // Name
                    Text('الاسم الكامل *', style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor)),
                    verticalSpace8,
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderColor)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    verticalSpace16,
                    
                    // Row for Plan and Phone
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('خطة الاشتراك', style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor)),
                              verticalSpace8,
                              DropdownButtonFormField<int?>(
                                initialValue: selectedPlanId,
                                isExpanded: true,
                                style: TextStylesManager.medium14.copyWith(color: ColorsManager.mainText),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderColor)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: [
                                  const DropdownMenuItem(value: null, child: Text('بدون خطة', overflow: TextOverflow.ellipsis)),
                                  ...cubit.subscriptionsList.map((sub) => DropdownMenuItem(
                                    value: sub.id,
                                    child: Text(sub.name, overflow: TextOverflow.ellipsis),
                                  )),
                                  if (selectedPlanId != null && !cubit.subscriptionsList.any((sub) => sub.id == selectedPlanId))
                                    DropdownMenuItem(
                                      value: selectedPlanId,
                                      child: Text(teacher.subscription?.name ?? 'خطة ($selectedPlanId)', overflow: TextOverflow.ellipsis),
                                    ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    selectedPlanId = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        horizontalSpace16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('رقم الجوال', style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor)),
                              verticalSpace8,
                              TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderColor)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    verticalSpace16,
                    
                    // Row for Quick Actions and End Date
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('إجراءات سريعة للاشتراك', style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor)),
                              verticalSpace8,
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        cubit.renewSubscription(id: teacher.id, months: 6);
                                        Navigator.pop(dialogContext);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        side: BorderSide(color: ColorsManager.primaryColor.withValues(alpha: 0.3)),
                                        backgroundColor: ColorsManager.isDark ? ColorsManager.primaryColor.withValues(alpha: 0.1) : const Color(0xFFE8F5E9),
                                      ),
                                      child: FittedBox(child: Text('تجديد (6+\nأشهر)', textAlign: TextAlign.center, style: TextStyle(color: ColorsManager.primaryColor, fontSize: 12, fontWeight: FontWeight.bold))),
                                    ),
                                  ),
                                  horizontalSpace8,
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        cubit.removeSubscription(id: teacher.id);
                                        Navigator.pop(dialogContext);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                                        backgroundColor: ColorsManager.isDark ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFFFEBEE),
                                      ),
                                      child: const FittedBox(child: Text('إلغاء الاشتراك', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        horizontalSpace16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('تاريخ انتهاء الاشتراك', style: TextStylesManager.bold14.copyWith(color: ColorsManager.primaryColor)),
                              verticalSpace8,
                              TextField(
                                controller: endDateController,
                                readOnly: true,
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (date != null) {
                                    setState(() {
                                      endDateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'mm/dd/yyyy',
                                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ColorsManager.borderColor)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    verticalSpace16,
                    
                    // Account Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorsManager.isDark ? ColorsManager.surfaceDark : const Color(0xFFF8FBF8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorsManager.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('حالة الحساب', style: TextStylesManager.bold16.copyWith(color: ColorsManager.primaryColor)),
                              verticalSpace4,
                              Text('الحساب نشط ويمكن تسجيل الدخول', style: TextStylesManager.medium12.copyWith(color: ColorsManager.secondaryText)),
                            ],
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (val) {
                              setState(() {
                                isActive = val;
                              });
                            },
                            activeThumbColor: const Color(0xFF00B778),
                          ),
                        ],
                      ),
                    ),
                    verticalSpace24,
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              cubit.updateTeacher(
                                id: teacher.id,
                                name: nameController.text.isNotEmpty ? nameController.text : null,
                                phone: phoneController.text.isNotEmpty ? phoneController.text : null,
                                subscriptionId: selectedPlanId,
                                active: isActive,
                                subscriptionEndsAt: endDateController.text.isNotEmpty ? endDateController.text : null,
                              );
                              Navigator.pop(dialogContext);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFECA332),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, color: Colors.white, size: 20),
                                horizontalSpace8,
                                Text('حفظ التعديلات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        horizontalSpace16,
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: ColorsManager.borderColor),
                            ),
                            child: Text('إلغاء', style: TextStyle(color: ColorsManager.mainText, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      );
    },
  );
}

void showResetPasswordDialog(BuildContext context, AdminTeacherModel teacher) {
  final cubit = AdminTeachersCubit.get(context);
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(appTranslation().get('admin_reset_password')),
        content: Text('هل أنت متأكد من إعادة تعيين كلمة المرور لـ ${teacher.user.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(appTranslation().get('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.resetPassword(id: teacher.id);
              Navigator.pop(dialogContext);
            },
            child: Text(appTranslation().get('admin_reset_password')),
          ),
        ],
      );
    },
  );
}

void showToggleStatusDialog(BuildContext context, AdminTeacherModel teacher) {
  final cubit = AdminTeachersCubit.get(context);
  final actionStr = teacher.active ? appTranslation().get('admin_suspend') : appTranslation().get('admin_activate');
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(actionStr),
        content: Text('هل أنت متأكد أنك تريد $actionStr ${teacher.user.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(appTranslation().get('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.toggleTeacherStatus(teacher: teacher);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: teacher.active ? Colors.red : Colors.green),
            child: Text(actionStr),
          ),
        ],
      );
    },
  );
}

void showDeleteTeacherDialog(BuildContext context, AdminTeacherModel teacher) {
  final cubit = AdminTeachersCubit.get(context);
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(appTranslation().get('admin_delete')),
        content: Text(appTranslation().get('admin_confirm_delete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(appTranslation().get('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.deleteTeacher(id: teacher.id);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(appTranslation().get('admin_delete')),
          ),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:moean/core/models/teacher_model.dart';
import 'package:moean/core/theme/colors.dart';

class SubscriptionInfoCard extends StatelessWidget {
  final TeacherModel teacher;
  final VoidCallback onUpgradeTap;

  const SubscriptionInfoCard({
    super.key,
    required this.teacher,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSubscribed = teacher.isSubscribed && !teacher.isExpired;
    final isInTrial = teacher.isInTrial && !teacher.isExpired;

    final Color badgeBg = isSubscribed
        ? const Color(0xFFEAF7F2)
        : (isInTrial ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2));
    final Color badgeText = isSubscribed
        ? const Color(0xFF0E7A5E)
        : (isInTrial ? const Color(0xFFB45309) : const Color(0xFFDC2626));

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ColorsManager.surfacePrimary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDEEE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
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
              Row(
                children: [
                  Icon(
                    isSubscribed
                        ? Icons.bolt
                        : (isInTrial ? Icons.hourglass_top : Icons.lock_clock),
                    color: badgeText,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    teacher.planTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ColorsManager.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isSubscribed ? 'نشط' : (isInTrial ? 'تجربة' : 'منتهي'),
                  style: TextStyle(
                    color: badgeText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  teacher.expirationSubtitle,
                  style: TextStyle(
                    color: ColorsManager.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (!isSubscribed) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgradeTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  isInTrial ? 'ترقية الخطة الآن ⚡' : 'اشترك لمتابعة الاستخدام ⚡',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

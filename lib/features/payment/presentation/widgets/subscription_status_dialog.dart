import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/di/injections.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/routes.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_cubit.dart';
import 'package:moean/features/payment/presentation/cubit/subscription_state.dart';
import 'package:moean/features/profile/presentation/cubit/profile_cubit.dart';

class SubscriptionStatusDialog extends StatefulWidget {
  const SubscriptionStatusDialog({super.key});

  static Future<void> show(BuildContext context) {
    // Refresh subscription data in background if needed
    final subCubit = sl<SubscriptionCubit>();
    if (subCubit.currentSubscription == null) {
      subCubit.fetchCurrentSubscription();
    }

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SubscriptionStatusDialog(),
    );
  }

  @override
  State<SubscriptionStatusDialog> createState() => _SubscriptionStatusDialogState();
}

class _SubscriptionStatusDialogState extends State<SubscriptionStatusDialog> {
  @override
  void initState() {
    super.initState();
    final subCubit = sl<SubscriptionCubit>();
    if (subCubit.currentSubscription == null && subCubit.state is SubscriptionInitial) {
      subCubit.fetchCurrentSubscription();
    }
  }

  static String _formatArabicDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    const arabicMonths = [
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
    final monthName = (date.month >= 1 && date.month <= 12)
        ? arabicMonths[date.month - 1]
        : '${date.month}';
    return '${date.day} $monthName ${date.year}';
  }

  static String _formatRemainingDaysText(int days) {
    if (days <= 0) return 'انتهت الصلاحية';
    if (days == 1) return 'يوم واحد';
    if (days == 2) return 'يومان';
    if (days >= 3 && days <= 10) return '$days أيام';
    return '$days يوم';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: ColorsManager.isDark ? ColorsManager.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ColorsManager.isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
            bloc: sl<SubscriptionCubit>(),
            builder: (context, subState) {
              final current = sl<SubscriptionCubit>().currentSubscription;
              final teacher = sl<ProfileCubit>().profileModel?.teacher;

              // Determine plan attributes
              final bool isSubscribed = current?.isSubscribed ?? teacher?.isSubscribed ?? false;
              final bool isInTrial = current?.isInTrial ?? teacher?.isInTrial ?? false;
              final DateTime? trialEndsAt = current?.trialEndsAt ?? teacher?.trialEndsAt;
              final DateTime? subscriptionEndsAt = current?.subscriptionEndsAt ?? teacher?.subscriptionEndsAt;
              final DateTime? effectiveEndsAt = isSubscribed
                  ? subscriptionEndsAt
                  : (isInTrial ? trialEndsAt : (subscriptionEndsAt ?? trialEndsAt));

              // Calculate days
              int daysRemaining = 0;
              if (effectiveEndsAt != null) {
                final now = DateTime.now();
                if (effectiveEndsAt.isAfter(now)) {
                  daysRemaining = (effectiveEndsAt.difference(now).inHours / 24).ceil();
                }
              } else {
                daysRemaining = current?.trialDaysRemaining ?? teacher?.trialDaysRemaining ?? 0;
              }

              // Determine expiration
              final bool isExpired;
              if (isSubscribed) {
                isExpired = subscriptionEndsAt != null && subscriptionEndsAt.isBefore(DateTime.now());
              } else if (isInTrial) {
                isExpired = (trialEndsAt != null && trialEndsAt.isBefore(DateTime.now())) || daysRemaining <= 0;
              } else {
                isExpired = true;
              }

              // Determine exact state mode:
              // 1 = Subscribed Active
              // 2 = Expired
              // 3 = Trial Active
              final bool isModeSubscribed = isSubscribed && !isExpired;
              final bool isModeExpired = isExpired;

              // Plan title
              final String planTitle;
              if (isModeSubscribed) {
                planTitle = current?.plan?.name ?? teacher?.subscription?.name ?? 'فصل دراسي واحد';
              } else {
                planTitle = 'مجاني';
              }

              // Badge configuration
              final String badgeText;
              final Color badgeBg;
              final Color badgeTextColor;
              final IconData headerIcon;
              final Color headerIconBg;
              final Color headerIconColor;
              final String dateLabel;
              final String remainingValue;
              final String buttonText;
              final bool showUsage;

              if (isModeSubscribed) {
                badgeText = 'اشتراك نشط';
                badgeBg = const Color(0xFFD1FAE5);
                badgeTextColor = const Color(0xFF065F46);
                headerIcon = Icons.gpp_good_outlined;
                headerIconBg = const Color(0xFFD1FAE5);
                headerIconColor = const Color(0xFF0E7A5E);
                dateLabel = 'تاريخ انتهاء الاشتراك:';
                remainingValue = _formatRemainingDaysText(daysRemaining);
                buttonText = 'ترقية أو تجديد الاشتراك';
                showUsage = true;
              } else if (isModeExpired) {
                badgeText = 'منتهي';
                badgeBg = const Color(0xFFFEE2E2);
                badgeTextColor = const Color(0xFFDC2626);
                headerIcon = Icons.error_outline_rounded;
                headerIconBg = const Color(0xFFFEE2E2);
                headerIconColor = const Color(0xFFDC2626);
                dateLabel = isSubscribed ? 'تاريخ انتهاء الاشتراك:' : 'تاريخ انتهاء التجربة:';
                remainingValue = 'انتهت الصلاحية';
                buttonText = 'اشترك في باقة مدفوعة';
                showUsage = false;
              } else {
                // Trial Active
                badgeText = 'تجربة مجانية';
                badgeBg = const Color(0xFFFEF3C7);
                badgeTextColor = const Color(0xFF92400E);
                headerIcon = Icons.auto_awesome;
                headerIconBg = const Color(0xFFFEF3C7);
                headerIconColor = const Color(0xFFD97706);
                dateLabel = 'تاريخ انتهاء التجربة:';
                remainingValue = _formatRemainingDaysText(daysRemaining);
                buttonText = 'اشترك في باقة مدفوعة';
                showUsage = true;
              }

              // Usage statistics
              final int lessonsRemaining = current?.usage.lessonsRemainingToday ??
                  current?.plan?.lessonLimitPerDay ??
                  teacher?.subscription?.lessonLimitPerDay ??
                  15;
              final int aiRemaining = current?.usage.aiRemaining ??
                  teacher?.aiQuotaRemaining ??
                  current?.plan?.aiQuotaPerMonth ??
                  teacher?.subscription?.aiQuotaPerMonth ??
                  200;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Row: [Badge] ... [Title Column + Icon]
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStylesManager.bold13.copyWith(
                            color: badgeTextColor,
                          ),
                        ),
                      ),

                      // Plan Name & Icon Row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'خطة الاشتراك الحالية',
                                style: TextStylesManager.medium12.copyWith(
                                  color: ColorsManager.isDark
                                      ? ColorsManager.mutedDark
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                planTitle,
                                style: TextStylesManager.bold18.copyWith(
                                  color: const Color(0xFF0E7A5E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: headerIconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              headerIcon,
                              color: headerIconColor,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(
                    color: ColorsManager.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFF1F5F9),
                    thickness: 1.2,
                    height: 1,
                  ),
                  const SizedBox(height: 16),

                  // Expiration Date Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: ColorsManager.isDark
                          ? ColorsManager.surfaceDark.withValues(alpha: 0.5)
                          : const Color(0xFFF7FAF9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: Color(0xFF0E7A5E),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateLabel,
                              style: TextStylesManager.medium14.copyWith(
                                color: ColorsManager.isDark
                                    ? ColorsManager.mutedDark
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatArabicDate(effectiveEndsAt),
                          style: TextStylesManager.bold14.copyWith(
                            color: const Color(0xFF0E7A5E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Remaining Duration Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: ColorsManager.isDark
                          ? ColorsManager.surfaceDark.withValues(alpha: 0.5)
                          : const Color(0xFFF7FAF9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المدة المتبقية:',
                          style: TextStylesManager.medium14.copyWith(
                            color: ColorsManager.isDark
                                ? ColorsManager.mutedDark
                                : const Color(0xFF4B5563),
                          ),
                        ),
                        Text(
                          remainingValue,
                          style: TextStylesManager.bold14.copyWith(
                            color: const Color(0xFF0E7A5E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Usage Card (shown when trial or subscribed is active)
                  if (showUsage) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: ColorsManager.isDark
                            ? ColorsManager.surfaceDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ColorsManager.isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'تحضيرات اليوم المتبقية:',
                                style: TextStylesManager.bold14.copyWith(
                                  color: ColorsManager.isDark
                                      ? ColorsManager.textPrimaryDark
                                      : const Color(0xFF475569),
                                ),
                              ),
                              Text(
                                '$lessonsRemaining',
                                style: TextStylesManager.bold14.copyWith(
                                  color: const Color(0xFF0E7A5E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'رصيد الذكاء الاصطناعي المتبقي:',
                                style: TextStylesManager.bold14.copyWith(
                                  color: ColorsManager.isDark
                                      ? ColorsManager.textPrimaryDark
                                      : const Color(0xFF475569),
                                ),
                              ),
                              Text(
                                '$aiRemaining',
                                style: TextStylesManager.bold14.copyWith(
                                  color: const Color(0xFF0E7A5E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Upgrade / Subscribe Action Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.checkout);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E7A5E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            buttonText,
                            style: TextStylesManager.bold16.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.bolt_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

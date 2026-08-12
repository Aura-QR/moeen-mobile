import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moean/core/theme/colors.dart';
import 'package:moean/core/theme/text_styles.dart';
import 'package:moean/core/utils/constants/constants.dart';
import 'package:moean/core/utils/constants/spacing.dart';
import 'package:moean/features/referral/data/models/referral_dashboard_model.dart';
import 'package:moean/features/referral/presentation/cubit/referral_cubit.dart';
import 'package:moean/features/referral/presentation/cubit/referral_state.dart';
import 'package:moean/features/referral/presentation/widgets/referral_empty_history_widget.dart';
import 'package:moean/features/referral/presentation/widgets/referral_footer_widget.dart';
import 'package:moean/features/referral/presentation/widgets/referral_hero_card_widget.dart';
import 'package:moean/features/referral/presentation/widgets/referral_history_item_widget.dart';
import 'package:moean/features/referral/presentation/widgets/referral_stat_card_widget.dart';

class ReferralBodyWidget extends StatelessWidget {
  final ReferralDashboardModel dashboard;

  const ReferralBodyWidget({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
          ReferralHeroCardWidget(referralLink: dashboard.referralLink),
          verticalSpace16,
          // Stats Grid (Row 1)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ReferralStatCardWidget(
                    label: appTranslation().get('referral_discounts'),
                    value: '15% × ${dashboard.rewardsAvailableCount}',
                    hint: appTranslation().get('referral_discounts_hint'),
                    icon: Icons.redeem_outlined,
                    iconBgColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF8C00),
                  ),
                ),
                horizontalSpace12,
                Expanded(
                  child: ReferralStatCardWidget(
                    label: appTranslation().get('referral_qualified'),
                    value: '${dashboard.qualifiedReferrals} / ${dashboard.maxReferrals}',
                    icon: Icons.people_alt_outlined,
                    iconBgColor: ColorsManager.primaryColor.withValues(alpha: 0.1),
                    iconColor: ColorsManager.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          verticalSpace12,
          // Stats Row 2 (Remaining quota)
          ReferralStatCardWidget(
            label: appTranslation().get('referral_remaining'),
            value:
                '${dashboard.remainingReferrals} ${appTranslation().get('referral_remaining_suffix')}',
            hint: appTranslation().get('referral_max_note'),
            icon: Icons.workspace_premium_outlined,
            iconBgColor: const Color(0xFFEDE7F6),
            iconColor: const Color(0xFF7B1FA2),
          ),
          verticalSpace20,
          // History section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorsManager.surfacePrimary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorsManager.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      appTranslation().get('referral_history_title'),
                      style: TextStylesManager.bold16.copyWith(
                        color: ColorsManager.textPrimary,
                      ),
                    ),
                    // Refresh button
                    BlocBuilder<ReferralCubit, ReferralState>(
                      buildWhen: (_, s) => s is ReferralLoading || s is ReferralLoaded,
                      builder: (context, state) {
                        final isRefreshing = state is ReferralLoading;
                        return GestureDetector(
                          onTap: isRefreshing
                              ? null
                              : () => ReferralCubit.get(context).refresh(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                appTranslation().get('referral_refresh'),
                                style: TextStylesManager.medium14.copyWith(
                                  color: ColorsManager.primaryColor,
                                ),
                              ),
                              horizontalSpace4,
                              if (isRefreshing)
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ColorsManager.primaryColor,
                                  ),
                                )
                              else
                                Icon(Icons.refresh_rounded,
                                    size: 18,
                                    color: ColorsManager.primaryColor),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                verticalSpace16,
                // History list or empty state
                if (dashboard.history.isEmpty)
                  const ReferralEmptyHistoryWidget()
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dashboard.history.length,
                    separatorBuilder: (_, __) => verticalSpace8,
                    itemBuilder: (_, i) =>
                        ReferralHistoryItemWidget(item: dashboard.history[i]),
                  ),
              ],
            ),
          ),
          verticalSpace20,
          // Footer CTA
          const ReferralFooterWidget(),
          verticalSpace24,
        ],
      ),
    ),
    );
  }
}
